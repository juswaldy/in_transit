#!/usr/bin/python

import argparse
import pandas as pd
import pandas_profiling as pdprof
import pyodbc
import datetime
import os
import sys
sys.path.insert(1, '/home/jus/bin')

from dwconfig import *

def parse_args():
    desc = "Generate pandas_profiling report from Assets Staging"
    parser = argparse.ArgumentParser(description=desc)
    parser.add_argument('--targetfolder', type=str, default=None, help='Target folder to save the reports to', required=True)
    parser.add_argument('--tablename', type=str, default=None, help='Source Table', required=False)
    return check_args(parser.parse_args())

def check_args(args):
    return args

"""main"""
def main():

	## Parse arguments.
	args = parse_args()
	if args is None:
		print("Problem!")
		exit()

	conn = pyodbc.connect(hub_PROD, autocommit=True)

	cursor = conn.cursor()

	## Get the list of tables to profile.
	sql = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME IN ( 'TeamDynamixAssets', 'TelusAssets', 'KaseyaAgents', 'ADComputers', 'ExtronAssets' )"
	if args.tablename:
		sql += " AND TABLE_NAME = '{}'".format(args.tablename)
	sql += " ORDER BY TABLE_NAME"

	cursor.execute(sql)
	rows = cursor.fetchall()
	cursor.close()

	intermediate_file = "{}/x.html".format(args.targetfolder)

	## Go through each table.
	for row in rows:
		## Build default values from info schema.
		sql = """
			SELECT COLUMN_NAME, DATA_TYPE
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_SCHEMA = 'Staging'
			AND TABLE_NAME = '{}'
			ORDER BY ORDINAL_POSITION
		"""
		df = pd.read_sql(sql.format(row.TABLE_NAME), conn)
		df['default'] = df.apply(lambda row: type_defaults[row['DATA_TYPE']], axis=1)
		default_values = dict(zip(df.COLUMN_NAME, df.default))

		## Grab table and save profile.
		try:
			print("############### Processing Staging.{}".format(row.TABLE_NAME))
			sql = "SELECT * FROM Staging.{}".format(row.TABLE_NAME)
			df = pd.read_sql(sql, conn).fillna(value=default_values)
			profile = pdprof.ProfileReport(df, title=row.TABLE_NAME)
			profile.to_file(intermediate_file)
			final_file = "{}/{}.html".format(args.targetfolder, row.TABLE_NAME)
			s = open(intermediate_file).read()
			f = open(final_file, 'w')
			title_string = "{} - {}".format(row.TABLE_NAME, datetime.date.today().strftime("%a, %d %b %Y"))
			f.write(s.replace("title>{}".format(row.TABLE_NAME), "title>{}".format(title_string)).replace("top>{}".format(row.TABLE_NAME), "top>{}".format(title_string)))
			f.close()
			profile.to_file("{}/{}.json".format(args.targetfolder, row.TABLE_NAME))
		except Exception as e:
			print("############### Error with {}: {}".format(row.TABLE_NAME, e))

	os.remove(intermediate_file)

if __name__ == '__main__':
    main()
