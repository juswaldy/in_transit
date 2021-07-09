#!/usr/bin/python

import sqlparse
from sqlparse.sql import *
import argparse
import pyodbc
import sys
import re
from datetime import *
import os
from preprocessor import *
from metagetter import *
sys.path.insert(1, '/home/jus/bin')

import dwconfig

# Prepare token types.
starters = [ 'ALTER', 'BEGIN', 'BREAK', 'BULK INSERT', 'CLOSE', 'COMMIT', 'CONTINUE', 'CREATE', 'DBCC', 'DEALLOCATE', 'DECLARE', 'DELETE', 'DENY', 'DISABLE', 'DROP', 'ENABLE', 'EXEC', 'EXECUTE', 'EXIT', 'FETCH', 'GOTO', 'GRANT', 'IF', 'INSERT', 'KILL', 'MERGE', 'OPEN', 'OPENDATASOURCE', 'OPENQUERY', 'OPENROWSET', 'OPENXML', 'PRINT', 'RAISERROR', 'READTEXT', 'RECONFIGURE', 'RESTORE', 'RETURN', 'REVERT', 'REVOKE', 'ROLLBACK', 'SAVE', 'SELECT', 'SET', 'SETUSER', 'SHUTDOWN', 'TRUNC', 'TRUNCATE', 'UPDATE', 'UPDATETEXT', 'USE', 'WAITFOR', 'WHILE', 'WITH', 'WRITETEXT' ]
semicolon = Token(T.Punctuation, ';')
metaschema = 'Deps'

def parse_args():
    desc = "Parse sql objects and load into the Metacoder"
    parser = argparse.ArgumentParser(description=desc)
    parser.add_argument('--connection', type=str, default=None, help='Connection name from dwconfig.py', required=True)
    parser.add_argument('--sourcename', type=str, default=None, help='Name of the source to load', required=True)
    parser.add_argument('--resetmeta', action='store_true', help='Reset metadata tables?', required=False)
    parser.add_argument('--pattern', type=str, default=None, help='Supply a name pattern matching the objects you want to pull', required=False)
    parser.add_argument('--targetconn', type=str, default=None, help='Target db connection name from dwconfig.py', required=True)
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
				o.type,
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
	else:
		sql += """
			WHERE name LIKE 'TWU[_]%'
			OR name LIKE 'SP[_]TWU[_]%'
			OR name LIKE 'CUS[_]%'
			OR name LIKE 'FAST[_]%'
			OR name LIKE 'Jehu%'
			OR name LIKE 'Aqueduct%'
			OR name LIKE 'bookstore%'
			OR name LIKE 'Moodle%'
			OR name IN (
				-- Views.
				'Classifications',
				'GL_MASTER_COMPONENT_V',
				'SAM_STUDENTS',
				'STUDENT_DIRECTORY_V',

				-- Functions.
				'CalculatePaymentRequired',
				'FN_ROUTING_NO_CHECK_DIGIT',

				-- Stored Procedures.
				'IsIDOrgOrPerson',
				'MAKE_BLANK_DEGR_HIST_ROW_NOT_CURRENT'
			)
		"""
	sql += "ORDER BY name"
	cursor.execute(sql)
	rows = cursor.fetchall()
	cursor.close()
	return rows

''' Get all tables from INFORMATION_SCHEMA. '''
def get_all_tables(connection):
	conn = pyodbc.connect(connection, autocommit=True)
	cursor = conn.cursor()
	sql = """
		SELECT DISTINCT (CONCAT(TABLE_CATALOG, '.', TABLE_SCHEMA, '.', TABLE_NAME)) TableName FROM INFORMATION_SCHEMA.TABLES
		UNION
		SELECT DISTINCT (CONCAT(TABLE_CATALOG, '.', TABLE_SCHEMA, '.', TABLE_NAME)) TableName FROM INFORMATION_SCHEMA.ROUTINE_COLUMNS
	"""
	cursor.execute(sql)
	rows = cursor.fetchall()
	cursor.close()
	result = []
	for r in rows:
		result.append(r.TableName)
	return result

''' Get source metadata '''
def get_sourcemeta(connstring, sourcename):
	conn = pyodbc.connect(connstring, autocommit=True)
	cursor = conn.cursor()
	sql = "SELECT TOP 1 * FROM {}.Source WHERE SourceName = '{}'".format(metaschema, sourcename)
	cursor.execute(sql)
	rows = cursor.fetchall()
	cursor.close()
	return rows

''' Reset metadata db '''
def reset_meta(connstring):
	conn = pyodbc.connect(connstring, autocommit=False)
	cursor = conn.cursor()
	for t in ['Op', 'Token', 'OpAccess']:
		cursor.execute("TRUNCATE TABLE {}.{}".format(metaschema, t))
	cursor.commit()
	cursor.close()

''' Write metadata to db '''
def write_meta(connstring, header, detail, access):
	conn = pyodbc.connect(connstring, autocommit=False)
	cursor = conn.cursor()

	# Clear out tables.
	cursor.execute("SELECT OpId FROM {}.Op WHERE OpSourceId = ? AND OpType = ? AND OpSchema = ? AND OpName = ?".format(metaschema), header)
	row = cursor.fetchone()
	if row:
		header_id = row[0]
		cursor.execute("DELETE FROM {}.Op WHERE OpId = ?".format(metaschema), header_id)
		cursor.execute("DELETE FROM {}.Token WHERE TokenOpId = ?".format(metaschema), header_id)
		cursor.commit()

	# Write header.
	cursor.execute("INSERT INTO {}.Op (OpSourceId, OpType, OpSchema, OpName) VALUES (?, ?, ?, ?)".format(metaschema), header)
	cursor.execute("SELECT @@IDENTITY AS header_id")
	header_id = cursor.fetchone()[0]
	cursor.commit()

	# Write detail.
	cursor.fast_executemany = True
	try:
		cursor.executemany("INSERT INTO {}.Token (TokenOpId, TokenMode, TokenSequence, TokenType, TokenInstance) VALUES ({}, ?, ?, ?, ?)".format(metaschema, header_id), detail)
	except pyodbc.DatabaseError as err:
		conn.rollback()
	else:
		conn.commit()

	# Write access if specified.
	if access:
		cursor.fast_executemany = True
		try:
			cursor.executemany("INSERT INTO {}.OpAccess (OpId, OpSegment, OpAccessType, Tablename) VALUES ({}, ?, ?, ?)".format(metaschema, header_id), access)
		except pyodbc.DatabaseError as err:
			conn.rollback()
		else:
			conn.commit()

	cursor.close()

"""main"""
def main():

	## Parse arguments.
	args = parse_args()
	if args is None:
		print("Problem!")
		exit()

	# Prepare source meta.
	objects = get_objects(getattr(dwconfig, args.connection), args.pattern)
	targetconn = getattr(dwconfig, args.targetconn)
	sourcemeta = get_sourcemeta(targetconn, args.sourcename)
	source_id = sourcemeta[0].SourceId
	reset_meta(targetconn) if args.resetmeta else None

	# Normalize all_tables for lookup later.
	all_tables = list(map(str.upper, get_all_tables(getattr(dwconfig, args.connection))))
	all_tables_normalized = all_tables
	all_tables_normalized.extend(list(map(lambda x: '.'.join(x.split('.')[1:]), all_tables)))
	all_tables_normalized.extend(list(map(lambda x: x.split('.')[-1], all_tables)))

	for o in objects:
		print(o.name)
		unprocessed, no_comments, preprocessed, no_whitespace = preprocess(o.definition)

		prelim = {
			'U': unprocessed,
			'C': no_comments,
			'P': preprocessed,
			'W': no_whitespace
		}
		#prelim = { 'P': preprocessed }

		# Prepare header row.
		header = (source_id, o.type.strip(), o.schema_name, o.name)

		# Gather detail rows.
		detail = []
		access = []
		table_aliases = []
		for k, v in prelim.items():
			p = (sqlparse.parse(v) if k != 'W' else v)

			# Prepare detail rows.
			for i, t in enumerate(TokenList(p).flatten()):
				detail.append((k, i+1, str(t.ttype).replace('Token.', ''), t.value))

			# Only for preprocessed no whitespaces: prepare access rows.
			if k == 'P':
				i = 0
				for x in p:
					# Prepare tablenames and aliases.
					tables = list(filter(lambda t:
						# Not temp tables nor variables.
						t[0] not in ['#', '@'] \
						# Either db.schema.table or dbo.
						and (t.count('.') in [0, 2] or 'dbo' in t),
						get_query_tables(x.value)
					))
					table_aliases = get_query_table_aliases(x.value)

					if tables:
						i += 1

						# Figure out the statement and its type.
						stmt = (Statement(x) if isinstance(x, Statement) else None)
						stmt_type = (stmt.get_type() if stmt else 'UNKNOWN')
						stmt = TokenList(x)

						# Generate access row if possible.
						if stmt_type == 'UNKNOWN':
							if stmt[0].value in [ 'TRUNC', 'TRUNCATE' ]:
								access.append((i, 'TRUNCATE', tables[0]))
							elif re.search(r"^\s*(IF|WHILE)[^\r\n]*\(?[ \t]*SELECT[ \t]+", stmt.value):
								access.append((i, 'SELECT', tables[0]))
						elif stmt_type in [ 'INSERT', 'UPDATE', 'DELETE' ]:
							target = tables[0]
							if target in table_aliases:
								access.append((i, stmt_type, table_aliases[target]))
							else:
								access.append((i, stmt_type, target))
						elif stmt_type in [ 'DROP', 'SELECT' ]:
							for t in tables:
								access.append((i, stmt_type, t))
						elif stmt_type in [ 'CREATE' ]:
							tables = list(filter(lambda t:
								t.strip('[]').upper() in all_tables_normalized,
								tables
							))
							for t in tables:
								access.append((i, stmt_type, t))

		# Write to db.
		write_meta(targetconn, header, detail, access)

if __name__ == '__main__':
    main()
