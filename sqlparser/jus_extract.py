#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright (C) 2009-2018 the sqlparse authors and contributors
# <see AUTHORS file>
#
# This example is part of python-sqlparse and is released under
# the BSD License: https://opensource.org/licenses/BSD-3-Clause
#
# This example illustrates how to extract table names from nested
# SELECT statements.

# Source
#   https://github.com/andialbrecht/sqlparse/issues/157

import sys
import sqlparse
from sqlparse.sql import IdentifierList, Identifier
from sqlparse.tokens import Keyword, DML
import sql_metadata as meta
import itertools

import unittest


def is_subselect(parsed):
    if not parsed.is_group:
        return False
    for item in parsed.tokens:
        if item.ttype is DML and item.value.upper() == 'SELECT':
            return True
    return False


def extract_from_part(parsed):
    from_seen = False
    for item in parsed.tokens:
        if item.is_group:
            for x in extract_from_part(item):
                yield x
        if from_seen:
            if is_subselect(item):
                for x in extract_from_part(item):
                    yield x
            elif item.ttype is Keyword and item.value.upper() in ['ORDER', 'GROUP', 'BY', 'HAVING', 'GROUP BY', 'ORDER BY']:
                from_seen = False
                StopIteration
            else:
                yield item
        if item.ttype is Keyword and item.value.upper() == 'FROM':
            from_seen = True


def extract_table_identifiers(token_stream):
    for item in token_stream:
        if isinstance(item, IdentifierList):
            for identifier in item.get_identifiers():
                value = identifier.value.replace('"', '').lower()
                yield value
        elif isinstance(item, Identifier):
            value = item.value.replace('"', '').lower()
            yield value

def clean_table_name(table_name):
    import re
    table_name = table_name.strip()
    if table_name.startswith('admin.'):
        table_name = table_name[6:]
    # in case of alias, return the original relation name
    # "foo as f"
    # "foo f"
    if re.match(r'^[\w]+\s+(as\s+)?\w+$', table_name):
        table_name = table_name.split()[0]
    return table_name


def extract_tables(sql):
    extracted_tables = []
    statements = list(sqlparse.parse(sql))
    for statement in statements:
        if statement.get_type() != 'UNKNOWN':
            stream = extract_from_part(statement)
            extracted_tables.append(set(list(extract_table_identifiers(stream))))
    ret1 = list(itertools.chain(*extracted_tables))
    ret2 = [ ]
    for x in ret1:
        # if "foo as f1" then return just "foo"
        if ' as ' in x:
            ret2.append(x.split()[0])
        else:
            ret2.append(x)
    ret3 = [clean_table_name(tn) for tn in ret2]
    return list(set(ret3)) # make unique



if __name__ == '__main__':
    sql = open(sys.argv[1]).read()

    for s in sqlparse.parse(sql):
	    print(s)
	    print('Tables: {}'.format(meta.get_query_tables(s.value)))
	    print('Table Aliases: {}'.format(meta.get_query_table_aliases(s.value)))
	    print('Columns: {}'.format(meta.get_query_columns(s.value)))
	    print('-'*80)
