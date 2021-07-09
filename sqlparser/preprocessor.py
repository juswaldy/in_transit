import sqlparse
from sqlparse.sql import *
import uuid
import re

# Prepare token types.
starters = [ 'ALTER', 'BEGIN', 'BREAK', 'BULK INSERT', 'CLOSE', 'COMMIT', 'CONTINUE', 'CREATE', 'DBCC', 'DEALLOCATE', 'DECLARE', 'DELETE', 'DENY', 'DISABLE', 'DROP', 'ENABLE', 'EXEC', 'EXECUTE', 'EXIT', 'FETCH', 'GOTO', 'GRANT', 'IF', 'INSERT', 'KILL', 'MERGE', 'OPEN', 'OPENDATASOURCE', 'OPENQUERY', 'OPENROWSET', 'OPENXML', 'PRINT', 'RAISERROR', 'READTEXT', 'RECONFIGURE', 'RESTORE', 'RETURN', 'REVERT', 'REVOKE', 'ROLLBACK', 'SAVE', 'SELECT', 'SET', 'SETUSER', 'SHUTDOWN', 'TRUNC', 'TRUNCATE', 'UPDATE', 'UPDATETEXT', 'USE', 'WAITFOR', 'WHILE', 'WITH', 'WRITETEXT' ]
semicolon = Token(T.Punctuation, ';')

''' Create a hash table and replace parens with their hash values. This works together with decode_parens(), where we replace the hash back with the actual values. '''
def encode_parens(tokenlist, result=[], parens={}):
	for t in tokenlist.tokens:
		if t.is_group:
			if isinstance(t, Parenthesis):
				k = str(uuid.uuid4())
				v = t.value
				parens[k] = v
				u = Parenthesis([Token(T.Text, "{}".format(k))])
				result.append(u)
			else:
				result, parens = encode_parens(t, result, parens)
		else:
			result.append(t)
	return result, parens

''' Replace parens with their actual values from the given dictionary. This works together with encode_parens(), where we originally create the hash table. '''
def decode_parens(tokens, parens):
	result = tokens.value
	for k in parens.keys():
		result = result.replace(k, parens[k])
	return sqlparse.parse(result)

''' Split the given tokenlist into statements using semicolons. '''
def split_into_statements(tokens):
	result = []
	next_tokens = []
	for t in tokens.flatten():
		if next_tokens:
			if t.value in next_tokens:
				next_tokens = []
		else:
			if t.value in starters:
				# Close off the previous statement.
				result.append(semicolon)

				# Handle special cases.
				if t.match(T.DML, 'UPDATE'): # If UPDATE, next will be SET.
					next_tokens = [ 'SET' ]
				elif t.match(T.DML, 'INSERT'): # If INSERT, next will be VALUES or SELECT.
					next_tokens = [ 'VALUES', 'SELECT' ]
				elif t.match(T.Keyword, 'GRANT'): # If GRANT, next will be the permissions TO principal.
					next_tokens = [ 'TO' ]

			elif re.search(r"END\s+IF", t.value, re.IGNORECASE):
				# Close off the previous statement.
				result.append(semicolon)
				t = Token(T.Keyword, 'IF')

		result.append(t)

	return TokenList(result)

''' Preprocess the given sql string. '''
def preprocess(sql):
	unprocessed = sql
	s = sqlparse.format(sql, keyword_case="upper", strip_comments=True, truncate_strings=8000)
	no_comments = s

	# Remove CREATE statement.
	s = re.sub(r"^\s*CREATE\s+VIEW\s+[\w\[\]\.\(\),@]+\s+AS\s+", '', s)
	#m = re.search(r"^\s*CREATE\s+(FUNCTION|PROCEDURE|TRIGGER)\s+[\w\s\[\]\(\)\.,@=']+?AS\s+", s)
	#print(re.escape(m.group(0)))
	s = re.sub(r"^\s*CREATE\s+(FUNCTION|PROCEDURE|TRIGGER)\s+[\w\s\[\]\(\)\.,@=']+?AS\s+", '', s)

	# Separate the CTEs.
	a = sqlparse.parse(re.sub(r"\bWITH\b", ';WITH', s))

	# Go through CTEs and find their edges.
	b = []
	for x in a:
		if x.token_first().match(T.CTE, 'WITH'):
			# Find the next DML.
			idx, token = x.token_next_by(t=T.DML)
			next_starter = None

			if token:
				# Complete the DML.
				if token.match(T.DML, 'SELECT'): # SELECT is OK.
					ttype = token.ttype
				elif token.match(T.DML, 'INSERT'): # A CTE INSERT must have an accompanying SELECT.
					idx, token = x.token_next_by(m=(T.DML, 'SELECT'), idx=idx)
				elif token.match(T.DML, 'UPDATE'): # An UPDATE must have an accompanying SET.
					idx, token = x.token_next_by(m=(T.Keyword, 'SET'), idx=idx)
				elif token.match(T.DML, 'DELETE'): # DELETE is OK.
					ttype = token.ttype
				else:
					raise Exception("Can't have a CTE without DML")

				# Find the next starter.
				next_starter = x.token_matching([lambda tk: tk.value in starters], idx+1)
				if next_starter:
					# Group the tokens together up to the next starter.
					y = x.group_tokens(TokenList, 0, x.token_index(next_starter)-1)
				else:
					# If no more starters, this is the last group, grab every token.
					y = x.group_tokens(TokenList, 0, len(x.tokens)-1)

				# Close with a semicolon.
				y.insert_after(len(y.tokens)-1, semicolon)
				b.append(y)

				# If not the last group, grab all tokens until the end and append to result.
				if next_starter:
					y = x.group_tokens(TokenList, x.token_index(next_starter), len(x.tokens)-1)
					y.insert_after(len(y.tokens)-1, semicolon)
					b.append(y)

		else:
			b.append(x)

	# Go through statements again and take care of the non-CTEs.
	c = []
	for x in b:
		if x.token_first().match(T.CTE, 'WITH'):
			c.append(x)
		else:
			y = []
			parens = {}
			y, parens = encode_parens(x, y, parens)
			y = split_into_statements(TokenList(y))
			s = decode_parens(y, parens)
			c.append(TokenList(s))

	# Remove extra semicolons, BEGINs, ENDs, GOs, UNIONs, RETURNs.
	d = []
	for x in sqlparse.parse(TokenList(c).value):
		if len(re.sub(r"(ELSE|BEGIN|END|GO|UNION|;)+", '', x.value).strip()) > 0:
			removals = {
				r"\bELSE\b\s*;": ';',
				r"\s*\bEND\s+ELSE\s+BEGIN\b\s*": ';',
				r"\s*(\bELSE\b)?\s*\bBEGIN\b\s*": ' ',
				r"\s*(\bEND\b|\s)*\bEND\b\s*;": ';',
				r"\s*\bUNION(\s+ALL)?\b\s*;": ';',
				#r";+": ';',
				r"\bRETURN\b[\W]*;": ';',
			}
			for k, v in removals.items():
				if re.search(k, x.value, re.IGNORECASE):
					#print(k, '-'*80)
					#print('BEFORE', x.ttype, x.value)
					x = Token(x.ttype, re.sub(k, v, x.value))
					#print('AFTER:', x.ttype, x.value)

			if len(re.sub(r";+", '', x.value).strip()) > 0:
				d.append(x)

	# Miscellaneous fixes.
	e = []
	for x in TokenList(d).flatten():
		if x.ttype in [ T.Name.Builtin, T.Operator.Comparison ]:
			x = Token(x.ttype, x.value.upper())
		e.append(x)

	preprocessed = TokenList(e).value

	no_whitespace = TokenList([t for t in TokenList(e).flatten() if t.ttype not in [ T.Whitespace, T.Newline ]])

	return unprocessed, no_comments, preprocessed, no_whitespace

