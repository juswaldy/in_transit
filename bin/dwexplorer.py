#!/usr/bin/python

import json

# Config.
db = 'FinancialReporting'
schema = 'INFORMATION_SCHEMA'
tables = [
	'CHECK_CONSTRAINTS',
	'COLUMN_DOMAIN_USAGE',
	'COLUMN_PRIVILEGES',
	'COLUMNS',
	'CONSTRAINT_COLUMN_USAGE',
	'CONSTRAINT_TABLE_USAGE',
	'DOMAIN_CONSTRAINTS',
	'DOMAINS',
	'KEY_COLUMN_USAGE',
	'PARAMETERS',
	'REFERENTIAL_CONSTRAINTS',
	'ROUTINES',
	'ROUTINE_COLUMNS',
	'SCHEMATA',
	'TABLE_CONSTRAINTS',
	'TABLE_PRIVILEGES',
	'TABLES',
	'VIEW_COLUMN_USAGE',
	'VIEW_TABLE_USAGE',
	'VIEWS'
]

# Count rows.
sql = []
for t in tables:
	print(t)
	tablename = "{}.{}".format(schema, t)
	sql.append("SELECT '{0}' Name, COUNT(*) Count FROM {0}".format(tablename))
countsql = "\nUNION\n".join(sql)

exit()

notebook = {
    "metadata": {
        "kernelspec": {
            "name": "SQL",
            "display_name": "SQL",
            "language": "sql"
        },
        "language_info": {
            "name": "sql",
            "version": ""
        }
    },
    "nbformat_minor": 2,
    "nbformat": 4,
    "cells": [
        {
            "cell_type": "markdown",
            "source": [
                "# Exploring {} `INFORMATION_SCHEMA`".format(db)
            ]
        },
        {
            "cell_type": "code",
            "source": [
                "USE {};".format(db)
            ],
            "outputs": []
        },
        {
            "cell_type": "code",
            "source": [
                countsql
            ],
            "outputs": []
        },
        {
            "cell_type": "code",
            "source": [
                "SELECT TOP 9 * FROM INFORMATION_SCHEMA.COLUMNS ORDER BY NEWID();"
            ],
            "outputs": []
        }
    ]
}

print(json.dumps(notebook))
