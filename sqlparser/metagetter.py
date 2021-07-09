from typing import Iterator, List, Tuple, Optional, Dict
import sqlparse
from sqlparse.sql import *

# Prepare token types.
ignored_ttypes = ( T.Text.Whitespace, T.Text.Whitespace.Newline, T.Comment.Single, T.Comment.Multiline )
semicolon = Token(T.Punctuation, ';')

''' Normalize token: convert to upper case and remove whitespaces. '''
def normalize(token: sqlparse.sql.Token) -> str:
	return token.value.translate(str.maketrans("", "", " \n\t\r")).upper()

''' Make unique list while maintaining order. '''
def unique(_list: List) -> List:
	result = []
	for item in _list:
		if item not in result:
			result.append(item)
	return result

''' Get flattened list of relevant tokens. '''
def get_query_tokens(query: str) -> List[sqlparse.sql.Token]:
	parsed = sqlparse.parse(query)
	tokens = TokenList(parsed[0].tokens).flatten()
	return [token for token in tokens if token.ttype not in ignored_ttypes ]

''' Return table names in a database.schema.table format. '''
def format_tablenames(tables: List[str], tokens: List[sqlparse.sql.Token], index: int, last_keyword: str) -> List[str]:

	token = tokens[index]
	last_token = tokens[index - 1].value.upper() if index > 0 else None
	next_token = tokens[index + 1].value.upper() if index + 1 < len(tokens) else None

	if (
		last_keyword
		in [
			"FROM",
			"JOIN",
			"INNERJOIN",
			"FULLJOIN",
			"FULLOUTERJOIN",
			"LEFTJOIN",
			"RIGHTJOIN",
			"LEFTOUTERJOIN",
			"RIGHTOUTERJOIN",
			"INTO",
			"UPDATE",
			"TABLE",
		]
		and last_token not in ["AS", "WITH"]
		and token.value not in ["AS", "SELECT"]
		and token.ttype not in [ T.Keyword ]
	):
		if last_token == "." and next_token != ".":
			# we have database.table notation example
			table_name = "{}.{}".format(tokens[index - 2], tokens[index])
			if len(tables) > 0:
				tables[-1] = table_name
			else:
				tables.append(table_name)

		schema_notation_match = (T.Name, ".", T.Name, ".", T.Name)
		schema_notation_tokens = (
			(
				tokens[index - 4].ttype,
				tokens[index - 3].value,
				tokens[index - 2].ttype,
				tokens[index - 1].value,
				tokens[index].ttype,
			)
			if len(tokens) > 4
			else None
		)
		if schema_notation_tokens == schema_notation_match:
			# we have database.schema.table notation example
			table_name = "{}.{}.{}".format(
				tokens[index - 4], tokens[index - 2], tokens[index]
			)
			if len(tables) > 0:
				tables[-1] = table_name
			else:
				tables.append(table_name)
		elif normalize(tokens[index - 1]) not in [",", last_keyword]:
			# it's not a list of tables, e.g. SELECT * FROM foo, bar
			# hence, it can be the case of alias without AS, e.g. SELECT * FROM foo bar
			pass
		else:
			table_name = str(token.value.strip("`"))
			tables.append(table_name)

	return tables

''' Get list of tables referenced in a query. '''
def get_query_tables(query: str) -> List[str]:
	tables = []
	last_keyword = None

	table_syntax_keywords = [
		# SELECT queries
		"FROM",
		"WHERE",
		"JOIN",
		"INNERJOIN",
		"FULLJOIN",
		"FULLOUTERJOIN",
		"LEFTOUTERJOIN",
		"RIGHTOUTERJOIN",
		"LEFTJOIN",
		"RIGHTJOIN",
		"CROSSJOIN",
		"ON",
		"UNION",
		"UNIONALL",
		# INSERT queries
		"INTO",
		"VALUES",
		# UPDATE queries
		"UPDATE",
		"SET",
		# Hive queries
		"TABLE",  # INSERT TABLE
	]

	# print(query, get_query_tokens(query))
	query = query.replace('"', "")
	tokens = get_query_tokens(query)

	for index, token in enumerate(tokens):
		# remove whitespaces from token value and uppercase
		token_val_norm = normalize(token)

		# print([token, token_val_norm, token.ttype, last_keyword])

		if token.is_keyword and token_val_norm in table_syntax_keywords:
			# keep the name of the last keyword, the next one can be a table name
			last_keyword = token_val_norm
			# print('keyword', last_keyword)
		elif str(token) == "(" and last_keyword in ["INTO", "VALUES"]:
			# reset the last_keyword for INSERT `foo` VALUES(id, bar) ...
			# reset the last_keyword for INSERT `foo` (col1, col2) VALUES(id, bar) ...
			last_keyword = None
		elif token.is_keyword and token_val_norm in ["FORCE", "ORDER", "GROUPBY"]:
			# reset the last_keyword for queries like:
			# "SELECT x FORCE INDEX"
			# "SELECT x ORDER BY"
			# "SELECT x FROM y GROUP BY x"
			last_keyword = None
		elif (
			token.is_keyword
			and token_val_norm == "SELECT"
			and last_keyword in ["INTO", "TABLE"]
		):
			# reset the last_keyword for "INSERT INTO SELECT" and "INSERT TABLE SELECT" queries
			last_keyword = None
		elif token.ttype is T.Name or token.is_keyword:
			tables = format_tablenames(tables, tokens, index, last_keyword)

	return unique(tables)

''' Get hash of alias => table. '''
def get_query_table_aliases(query: str) -> Dict[str, str]:
	result = dict()
	last_keyword_token = None
	last_last_keyword_token = None
	last_last_keyword_token_val_norm = None
	last_table_name = None

	table_markers = [
		"FROM",
		"JOIN",
		"INNERJOIN",
		"FULLJOIN",
		"FULLOUTERJOIN",
		"LEFTOUTERJOIN",
		"RIGHTOUTERJOIN",
		"LEFTJOIN",
		"RIGHTJOIN",
		"CROSSJOIN"
	]

	tokens = iter(get_query_tokens(query))
	for t in tokens:
		val = normalize(t)
		if val in table_markers:
			table_name = next(tokens)
			if table_name.ttype != T.Punctuation:
				alias = None
				try:
					as_alias_on = next(tokens)
					x = normalize(as_alias_on)
					if x == 'AS':
						alias = next(tokens).value
					elif x in table_markers or x in [ 'ON', 'WHERE', 'GROUPBY', 'UNION', 'UNIONALL', 'EXCEPT', 'INTERSECT' ] or as_alias_on.ttype == T.Punctuation:
						alias = table_name.value
					else:
						alias = as_alias_on.value
				except StopIteration:
					alias = ''

				result[alias] = table_name.value

	# Add missed tables.
	for table in get_query_tables(query):
		if table not in result.keys() and table not in result.values():
			result[table] = table

	return result

''' Get referenced column names. '''
def get_query_columns(query: str) -> List[str]:
	columns = []
	last_keyword = None
	last_token = None

	# these keywords should not change the state of a parser
	# and not "reset" previously found SELECT keyword
	keywords_ignored = [
		"AS",
		"AND",
		"OR",
		"IN",
		"IS",
		"NULL",
		"NOT",
		"NOT NULL",
		"LIKE",
		"CASE",
		"WHEN",
		"DISTINCT",
		"UNIQUE",
	]

	# these keywords are followed by columns reference
	keywords_before_columns = ["SELECT", "WHERE", "ORDER BY", "ON"]

	# these function should be ignored
	# and not "reset" previously found SELECT keyword
	functions_ignored = [
		"COUNT",
		"MIN",
		"MAX",
		"FROM_UNIXTIME",
		"DATE_FORMAT",
		"CAST",
		"CONVERT",
	]

	tables_aliases = get_query_table_aliases(query)

	def resolve_table_alias(_table_name: str) -> str:
		if _table_name in tables_aliases:
			return tables_aliases[_table_name]
		return _table_name

	for token in get_query_tokens(query):
		if token.is_keyword and token.value.upper() not in keywords_ignored:
			# keep the name of the last keyword, e.g. SELECT, FROM, WHERE, (ORDER) BY
			last_keyword = token.value.upper()
		elif token.ttype is T.Name:
			# analyze the name tokens, column names and where condition values
			if (
				last_keyword in keywords_before_columns
				and last_token.value.upper() not in ["AS"]
			):
				if token.value.upper() not in functions_ignored:
					if str(last_token) == ".":
						# print('DOT', last_token, columns[-1])

						# we have table.column notation example
						# append column name to the last entry of columns
						# as it is a table name in fact
						table_name = resolve_table_alias(columns[-1])

						columns[-1] = "{}.{}".format(table_name, token)
					else:
						columns.append(str(token.value)) if token.ttype != T.Keyword else None
			elif last_keyword in ["INTO"] and last_token.ttype is T.Punctuation:
				# INSERT INTO `foo` (col1, `col2`) VALUES (..)
				#  print(last_keyword, token, last_token)
				columns.append(str(token.value).strip("`"))
		elif token.ttype is T.Wildcard:
			# handle * wildcard in SELECT part, but ignore count(*)
			# print(last_keyword, last_token, token.value)
			if last_keyword == "SELECT" and last_token.value != "(":

				if str(last_token) == ".":
					# handle SELECT foo.*
					table_name = resolve_table_alias(columns[-1])
					columns[-1] = "{}.{}".format(table_name, str(token))
				else:
					columns.append(str(token.value)) if token.ttype != T.Keyword else None

		last_token = token

	return unique(columns)

''' Make human readable format. '''
def humanize(num, suffix='B'):
    for unit in ['', 'k', 'M', 'G', 'T', 'P', 'E', 'Z']:
        if abs(num) < 1024.0:
            return "%3.1f %s%s" % (num, unit, suffix)
        num /= 1024.0
    return "%.1f%s%s" % (num, 'Yi', suffix)

