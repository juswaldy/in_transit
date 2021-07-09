#!/usr/bin/python

from typing import Iterator, Tuple
import sqlparse
from sqlparse.sql import *
import argparse
import pyodbc
import sys
import re
sys.path.insert(1, '/home/jus/bin')

import dwconfig

def parse_args():
    desc = "Parse sql objects"
    parser = argparse.ArgumentParser(description=desc)
    parser.add_argument('--connection', type=str, default=None, help='Connection name from dwconfig.py', required=False)
    parser.add_argument('--sqlfile', type=str, default=None, help='SQL file to parse', required=False)
    parser.add_argument('--token_format', type=str, default='cli', help='Formatting for each token: cli or adj', required=True)
    parser.add_argument('--pattern', type=str, default=None, help='Supply a name pattern matching the objects you want to pull', required=False)
    parser.add_argument('--leaves_only', action='store_true', help='Show tree leaves only?', required=False)
    parser.add_argument('--summary', action='store_true', help='Show summary only?', required=False)
    parser.add_argument('--flatten', action='store_true', help='Show parsed flattened?', required=False)
    return check_args(parser.parse_args())

def check_args(args):
    return args

''' Get objects and definitions from sql_modules '''
def get_objects(connection, name_pattern=None):
	conn = pyodbc.connect(connection, autocommit=True)
	#conn.setdecoding(pyodbc.SQL_WCHAR, encoding='utf-16le', ctype=pyodbc.SQL_WCHAR, to=str)
	cursor = conn.cursor()
	sql = """
		WITH base AS (
			SELECT
				m.object_id id,
				OBJECT_SCHEMA_NAME(m.object_id) schema_name,
				OBJECT_NAME(m.object_id) name,
				o.type_desc,
				m.definition
			FROM sys.sql_modules m
			JOIN sys.objects o ON m.object_id = o.object_id
		)
		SELECT *
		FROM base
	"""
	if name_pattern:
		sql += "WHERE name LIKE '{}'\n".format(name_pattern)
	sql += "ORDER BY name"
	cursor.execute(sql)
	rows = cursor.fetchall()
	cursor.close()
	return rows

def enumerate_tree(root, ignored_ttypes, flatten=True):
	tlist = sqlparse.parse(root)[0].flatten()
	for t in tlist:
		if t.ttype not in ignored_ttypes:
			value = re.sub(r"\s+", " ", t.value)
			value = re.sub(r"^\[(.*)\]$", r"\1", value)
			if t.ttype in [ T.Keyword, T.Keyword.CTE, T.Keyword.DDL, T.Keyword.DML, T.Keyword.Order, T.Name.Builtin, T.Operator.Comparison ]:
				value = value.upper() 
			print(str(t.ttype).replace("Token.", ""), value)

def ftoken(defn: str, ignored_ttypes):
	parsed = sqlparse.parse(defn)
	#print(parsed)
	for s in parsed:
		if len(s.tokens) == 1:
			print(s[0].ttype, s[0].value)
			p2 = sqlparse.parse(s[0].value)[0]
			size = len(p2.tokens)
			if size > 1:
				input()
		else:
			for t in s.tokens:
				if t.ttype not in ignored_ttypes:
					if t.ttype == None:
						ftoken(t.value)
					else:
						print(t.ttype, t.value)


def split_and_parse(defn: str) -> Iterator[Tuple[Statement, int]]:
    
	defn = defn.rstrip(';\n') # Remove the last separator to avoid getting an empty statement.

	lineno = 0
	idx_last = 0
	for sql_fragment in sqlparse.split(defn):

		# Figure out the range of the fragment in the definition.
		idx_first = idx_last
		idx_last = defn.find(sql_fragment, idx_first)
		assert idx_last != -1

		# Keep the line number current.
		lineno += defn.count('\n', idx_first, idx_last)

		# Remove statement separator.
		#sql_fragment = sql_fragment.rstrip(';')

		# Yield the parsed fragment and its line number.
		if len(sqlparse.parse(sql_fragment)) > 0:
			yield (sqlparse.parse(sql_fragment)[0], lineno + 1)


def format_token(token: Token, token_format: str):
	result = ''
	if token_format == 'cli':
		if isinstance(token, TokenList):
			# Show class name if the token is instance of TokenList.
			typename = type(token).__name__
		else:
			# As for Token, show the token type from ttype field.
			typename = 'Token(ttype={0})'.format(str(token.ttype).split('.')[-1])

		value = str(token)
		#if len(value) > 30:
		#	value = value[:29] + '...'
		value = re.sub(r'\s+', ' ', value)
		q = '"' if value.startswith("'") and value.endswith("'") else "'"

		details = {}
		if isinstance(token, TokenList):
			details['alias'] = token.get_alias()
			details['name'] = token.get_name()
			details['parent_name'] = token.get_parent_name()
			details['real_name'] = token.get_real_name()
		if isinstance(token, Identifier):
			details['ordering'] = token.get_ordering()
			details['typecast'] = token.get_typecast()
			details['is_wildcard'] = token.is_wildcard()

		result = '{type} {q}{value}{q} {detail}'.format(type=typename, q=q, value=value,
							  detail=repr(details) if details else '')
	elif token_format == 'adj':
		result = str(token).split(r'\s')[0]

	return result

def print_tree(tokens: TokenList, is_summary, ignored_types, ignored_ttypes, types_dict, token_format='cli', left=''):

	num_tokens = len(tokens)
	for i, token in enumerate(tokens):
		t = "{}|{}".format(type(token)._get_repr_name(token), token.ttype)
		types_dict[t] = types_dict[t] + 1 if t in types_dict.keys() else 1
		#types_dict[t] = types_dict[t] + 1 if t in types_dict.keys() else 1
		if not (isinstance(token, ignored_types) or token.ttype in ignored_ttypes):
			if token_format == 'cli':
				last = i + 1 == num_tokens
				horizontal_node = '├' if not last else '└'
				vertical_node = '│' if not last else '  '

				if not isinstance(token, TokenList):
					print('{left}{repr}'.format(left=left + horizontal_node, repr=format_token(token, token_format))) if not is_summary else None
				if isinstance(token, TokenList) and token.is_group:
					print_tree(token.tokens, is_summary, ignored_types, ignored_ttypes, types_dict, token_format, left=left + vertical_node)
			elif token_format == 'adj':
				if isinstance(token, TokenList) and token.is_group:
					print_tree(token.tokens, is_summary, ignored_types, ignored_ttypes, types_dict, token_format, left=token.value)
				elif len(left) > 0:
					print('{parent}||||||{child}'.format(parent=left, child=format_token(token, token_format))) if not is_summary else None


def print_object(defn, objname, is_summary, ignored_types, ignored_ttypes, types_dict, token_format, left):
	for statement, line in split_and_parse(defn):
		print('{}:{}'.format(objname, line)) if not is_summary else None
		print_tree(statement.tokens, is_summary, ignored_types, ignored_ttypes, types_dict, token_format, left)
		print() if not is_summary else None


"""main"""
def main():

	## Parse arguments.
	args = parse_args()
	if args is None:
		print("Problem!")
		exit()

	# Prepare ignored token types.
	ignored_types = ignored_ttypes = ()
	if not args.summary:
		ignored_ttypes = ( T.Text.Whitespace, T.Text.Whitespace.Newline, T.Comment.Single, T.Comment.Multiline )
		ignored_types = ( sqlparse.sql.Comment )

	# Print it.
	types_dict = {}
	if args.sqlfile:
		defn = open(args.sqlfile).read()
		if args.flatten:
			enumerate_tree(defn, ignored_ttypes)
		else:
			print_object(defn, args.sqlfile, args.summary, ignored_types, ignored_ttypes, types_dict, args.token_format, '')
	else:
		objects = get_objects(getattr(dwconfig, args.connection), args.pattern)
		for o in objects:
			if args.flatten:
				enumerate_tree(o.definition, ignored_ttypes)
			else:
				print_object(o.definition, "{}.{}".format(o.schema_name, o.name), args.summary, ignored_types, ignored_ttypes, types_dict, args.token_format, '')

	# Print summary.
	if args.summary:
		for t in sorted(types_dict.keys()):
			print("{}|{}".format(t, types_dict[t]))

if __name__ == '__main__':
    main()
