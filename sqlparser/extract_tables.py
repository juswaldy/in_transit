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

import sqlparse
from sqlparse.sql import IdentifierList, Identifier
from sqlparse.tokens import Keyword, DML
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
    # let's handle multiple statements in one sql string
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



class TestExtract(unittest.TestCase):

    def test_clean_table_name(self):
        tests = ((' foo ', 'foo'),
            ('admin.foo', 'foo'),
            ('foo as f','foo'),
            ('foo f', 'foo'),
            ('foo_bar1 as fb', 'foo_bar1')
            )
        for original, expected in tests:
            actual = clean_table_name(original)
            self.assertEqual(expected, actual, f'Original: {original}, Expected: {expected}, Actual: {actual}')

    def _helper(self, sql, expected):
        ret = extract_tables(sql)
        ret.sort()
        expected.sort()
        expected = [x.lower() for x in expected]
        self.assertEqual(ret, expected, f'SQL: {sql}\nExpected: {expected}\nReturned: {ret}')

    def test_basic(self):
        sql  = "select a,b,c from foo"
        expected = ['foo']
        self._helper(sql, expected)
        
    def test_case(self):
        sql  = "select a,b,c from foo"
        expected = ['FOO']
        self._helper(sql, expected)
        
        sql  = "select a,b,c from FOO"
        expected = ['foo']
        self._helper(sql, expected)

    def test_comment(self):
        sql  = "/* select a from foo; */ select b from bar; -- select c from foobar;"
        expected = ['bar']
        self._helper(sql, expected)

    def test_distinct(self):
        sql  = "select f1.a,f1.b,f1.c from foo as f1 join foo as f2 on f1.id=f2.id"
        expected = ['foo']
        self._helper(sql, expected)
    
    def test_subquery(self):
        sql  = "select f1.a,f1.b,f1.c from foo as f1 where f1 in (select distinct id from bar)"
        expected = ['foo', 'bar']
        self._helper(sql, expected)

        sql = """
    select K.a,K.b from (select H.b from (select G.c from (select F.d from
    (select E.e from A, B, C, D, E), F), G), H), I, J, K order by 1,2;
    """
        expected = ['A','B','C','D','E', 'F', 'G', 'H', 'I', 'J', 'K']
        self._helper(sql, expected)
        
        # !!! fails
        sql  = "select a from foo join (select a from bar) as b on b.id=foo.id"
        expected = ['foo','bar']
        #self._helper(sql, expected)
        

    def test_cte(self):
        sql  = "with mycte as (select id from foo) select b.id from bar as b join foo as f on b.id=f.id"
        expected = ['foo', 'bar']
        self._helper(sql, expected)
        
    def test_union(self):
        # !!! fails
        sql  = "select f from foo union select b from bar"
        expected = ['foo', 'bar']
        #self._helper(sql, expected)


if __name__ == '__main__':
    unittest.main()
