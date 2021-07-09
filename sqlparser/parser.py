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

def parse_args():
    desc = "Parse sql objects"
    parser = argparse.ArgumentParser(description=desc)
    parser.add_argument('--connection', type=str, default=None, help='Connection name from dwconfig.py', required=False)
    parser.add_argument('--sqlfile', type=str, default=None, help='SQL file to parse', required=False)
    parser.add_argument('--pattern', type=str, default=None, help='Supply a name pattern matching the objects you want to pull', required=False)
    parser.add_argument('--skipsource', action='store_true', help='Save the definition to file?', required=False)
    parser.add_argument('--sourcename', type=str, default=None, help='Name of the source to load', required=True)
    parser.add_argument('--targetfolder', type=str, default=None, help='Target folder to save the reports to', required=True)
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

''' Get view usage info. '''
def get_view_usage(connection):
	conn = pyodbc.connect(connection, autocommit=True)
	cursor = conn.cursor()
	sql = """
		WITH tabl AS (
			SELECT VIEW_NAME, TABLE_NAME
			FROM INFORMATION_SCHEMA.VIEW_TABLE_USAGE
		),
		col AS (
			SELECT VIEW_NAME, CONCAT(TABLE_NAME, '.', COLUMN_NAME) TABLE_NAME
			FROM INFORMATION_SCHEMA.VIEW_COLUMN_USAGE
		),
		combined AS (
			SELECT * FROM tabl
			UNION
			SELECT * FROM col
		)
		SELECT DISTINCT VIEW_NAME, TABLE_NAME
		FROM combined
		ORDER BY VIEW_NAME, TABLE_NAME
	"""
	cursor.execute(sql)
	rows = cursor.fetchall()
	cursor.close()
	view_usage = {}
	for r in rows:
		if r.VIEW_NAME in view_usage:
			view_usage[r.VIEW_NAME].append(r.TABLE_NAME)
		else:
			view_usage[r.VIEW_NAME] = [r.TABLE_NAME]
	return view_usage

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

main_template = """<head><title>{}</title>
<link rel="stylesheet" href="../css.css">
</head>
<body>
<h1>{}</h1>
<h2>Summary</h2>
<table>
<tr><td>Type</td><td>{}</td></tr>
<tr><td>Source</td><td>{} characters</td></tr>
<tr><td>Parsed</td><td>{} characters<br/>{} tokens</td></tr>
<tr><td>Whitespace removed</td><td>{} tokens</td></tr>
<tr><td>Parsed time</td><td>{}</td></tr>
<tr><td>Tables/Views</td><td>{}</td></tr>
{}
</table>
<h2>Detail<h2>
<table style="table-layout: fixed; width: 1420px;">
<thead><td width="2%">#</td><td width="73%">Segment</td><td width="25%">Prelim</td></thead>
{}
</table>
{}
</body>
"""

source_template = """
<h2>Source vs Parsed</h2>
<table>
<thead><td>Source</td><td>Parsed</td></thead>
<tr><td><pre>{}</pre></td><td><pre>{}</pre></td></tr>
</table>
"""

row_template = '<tr><td>{}</td><td style="overflow: hidden;"><pre>{}</pre></td><td>{}</td></tr>'

def html_list(items, listtype='ul'):
	result = ""
	if len(items) > 0:
		result = "<{}>".format(listtype)
		for i in items:
			result += "<li>{}</li>".format(i)
		result += "</{}>".format(listtype)
	return result
		
def html_hash(items, listtype='ul'):
	result = ""
	if len(items) > 0:
		result = "<{}>".format(listtype)
		for k, v in items.items():
			result += "<li>{} = {}</li>".format(k, v) if k != v else ""
		result += "</{}>".format(listtype)
	return result

"""main"""
def main():

	## Parse arguments.
	args = parse_args()
	if args is None:
		print("Problem!")
		exit()

	# Print it.
	types_dict = {}
	current_timestamp = datetime.now().strftime('%a, %d %b %Y %H:%M')
	if args.sqlfile:
		_, _, defn, _ = preprocess(open(args.sqlfile).read())
		print(sqlparse.format(defn, strip_comments=True, reindent=True))
		exit()
		p = sqlparse.parse(defn)
		for x in p:
			tables = get_query_tables(x.value)
			if tables:
				print('#'*80)
				print(x)
				print('-'*40)
				print('Tables: {}'.format(tables))
				print('Aliases: {}'.format(get_query_table_aliases(x.value)))
				print('Columns: {}'.format(get_query_columns(x.value)))
	else:
		objects = get_objects(getattr(dwconfig, args.connection), args.pattern)
		view_usage = get_view_usage(getattr(dwconfig, args.connection))
		all_tables = get_all_tables(getattr(dwconfig, args.connection))

		# Normalize all_tables for lookup later.
		all_tables_upper = list(map(str.upper, all_tables))
		all_tables_normalized = all_tables_upper
		all_tables_normalized.extend(list(map(lambda x: '.'.join(x.split('.')[1:]), all_tables_upper)))
		all_tables_normalized.extend(list(map(lambda x: x.split('.')[-1], all_tables_upper)))

		parsed_tables = []
		for o in objects:
			print(o.name)

			_, _, defn, _ = preprocess(o.definition)
			p = sqlparse.parse(defn)

			i = 0
			rows = []
			table_names = []
			for x in p:
				prelim = ""
				tables = get_query_tables(x.value)
				if tables:
					i += 1

					# Figure out the statement and its type.
					stmt = (Statement(x) if isinstance(x, Statement) else None)
					stmt_type = (stmt.get_type() if stmt else 'UNKNOWN')
					stmt = TokenList(x)

					# Take care of specific types and unknowns.
					if stmt[0].value in [ 'TRUNC', 'TRUNCATE', 'DECLARE', 'IF', 'WHILE' ]:
						if stmt[0].value in [ 'TRUNC', 'TRUNCATE' ]:
							stmt_type = 'TRUNCATE'
						elif stmt[0].value in [ 'DECLARE' ]:
							stmt_type = 'DECLARE'
						elif re.search(r"^\s*(IF|WHILE)[^\r\n]*\(?[ \t]*SELECT[ \t]+", stmt.value):
							stmt_type = 'SELECT'
					if stmt_type == 'UNKNOWN':
						stmt_type = stmt[0].value

					# Add preliminary analysis.
					prelim = "Type: {}<br/><br/>Tables/Views:<br/>{}<br/>Aliases:<br/>{}<br/>Columns:<br/>{}".format(stmt_type, html_list(tables), html_hash(get_query_table_aliases(x.value)), html_list(get_query_columns(x.value)))
					rows.append(row_template.format(i, x.value, prelim))

					# Gather table names for summary.
					for t in tables:
						if t[0] not in ['#', '@'] and t not in table_names and (t.count('.') in [0, 2] or 'dbo' in t):
							normalized = (t if t.count('.') == 0 else t.split('.')[-1].strip('[]').upper())
							dbname = (None if t.count('.') < 2 else t.split('.')[0].strip('[]').upper())
							if (
								normalized in all_tables_normalized
								or dbname in [
									'AQUEDUCT',
									'EPISUITE6',
									'ICS_NET',
									'KANCARD',
									'MASTER',
									'MSDB'
								]
							):
								table_names.append(t) if t not in table_names else None
								parsed_tables.append(t) if t not in parsed_tables else None
							

			# Prepare summary.
			source_chars = len(o.definition)
			parsed_chars = len(defn)
			parsed_tokens = sum(1 for token in TokenList(p).flatten())
			parsed_tokens_nowhitespace = sum(1 for token in TokenList(p).flatten() if token.ttype not in [ T.Whitespace, T.Newline ])
			current_timestamp = datetime.now().strftime('%a, %d %b %Y %H:%M')
			table_names = html_list(table_names, listtype='ol')
			from_infoschema = ""
			if o.type_desc == 'VIEW':
				from_infoschema = "<tr><td>From INFORMATION_SCHEMA</td><td>{}</td></tr>".format(html_list(sorted(view_usage[o.name]), 'ol')) if o.name in view_usage else None

			# Write the output file.
			source_portion = ("" if args.skipsource else source_template.format(o.definition, defn.replace(';', ";\n")))
			outfile = open('{}/{}.html'.format(args.targetfolder, o.name), 'w')
			outfile.write(main_template.format(o.name, o.name, o.type_desc, source_chars, parsed_chars, parsed_tokens, parsed_tokens_nowhitespace, current_timestamp, table_names, from_infoschema, "\n".join(rows), source_portion))
			outfile.close()

		# Write all tables from source INFORMATION_SCHEMA. Write parsed tables.
		outfile = open('{}/0.all_tables.txt'.format(args.targetfolder), 'w')
		outfile.write("\n".join(all_tables))
		outfile.close()
		outfile = open('{}/0.parsed_tables.txt'.format(args.targetfolder), 'w')
		outfile.write("\n".join(sorted(parsed_tables)))
		outfile.close()

	# Make index.html.
	current_timestamp = datetime.now().strftime('%a, %d %b %Y %H:%M')
	outfile = open('{}/index.html'.format(args.targetfolder), 'w')
	listing = '<head><link rel="stylesheet" href="../css.css"></head><h1>{} - {}</h1>'.format(args.sourcename, current_timestamp)
	listing += '<table><thead><td>Name</td><td>Modified</td><td>Size</td></thead>{}</table>'
	fileinfo = []
	for f in sorted(os.listdir(args.targetfolder)):
		fullpath = os.path.join(args.targetfolder, f)
		if os.path.isfile(fullpath) and f not in [ 'index.html', 'css.css' ]:
			size = os.path.getsize(fullpath)
			mtime = os.path.getmtime(fullpath)
			fileinfo.append('<tr><td><a href="{}">{}</a></td><td>{}</td><td>{}</td></tr>'.format(f, f, datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M:%S'), humanize(size)))
	outfile.write(listing.format(''.join(fileinfo)))
	outfile.close()

if __name__ == '__main__':
    main()
