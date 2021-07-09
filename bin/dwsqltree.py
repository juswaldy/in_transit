"""Print parsed SQL statement as a tree.

Uses Python 3 and sqlparse package.
"""

from typing import Iterator, Tuple
import argparse
import locale
import sys
import os
import re

import sqlparse
from sqlparse.sql import * #TokenList, Identifier, Statement
from sqlparse.tokens import *


def parsed_statement_and_coords(text: str) -> Iterator[Tuple[Statement, int]]:
    """
    Parse a text contains SQL statements.
    :param text: The text contains SQL statements.
    :return: Iterator yields tuples of parsed statement and its line number.
    """
    # Remove the last separator to avoid to get empty statement.
    text = text.rstrip(';\n')

    line_index = 0
    sql_end_index = 0
    for sql in sqlparse.split(text):
        sql_start_index = sql_end_index
        # Determine the coordinates of the statement.
        sql_end_index = text.find(sql, sql_start_index)
        assert sql_end_index != -1

        # Update the current line number.
        line_index += text.count('\n', sql_start_index, sql_end_index)

        # Remove semicolon at the end.
        sql = sql.rstrip(';')

        # Yield the parsed statement and line number.
        yield (sqlparse.parse(sql)[0], line_index + 1)


def repr_token(token: sqlparse.sql.Token):
    """
    Return a string that represents a SQL token.
    :param token: The token will be explained.
    :return: A single-line string that represents the token.
    """
    if isinstance(token, TokenList):
        # Show class name if the token is instance of TokenList.
        typename = type(token).__name__
    else:
        # As for Token, show the token type from ttype field.
        typename = 'Token(ttype={0})'.format(str(token.ttype).split('.')[-1])

    value = str(token)
    if len(value) > 100:
        value = value[:99] + '...'
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

    return '{type} {q}{value}{q} {detail}'.format(type=typename, q=q, value=value,
                                                  detail=repr(details) if details else '')


def print_tree(tokens: sqlparse.sql.TokenList, left=''):
    """
    Print SQL tokens as a tree.

    :param tokens: TokenList object to be printed.
    :param left: Left string printed for each lines. (normally it's for internal use)
    """
    ignored_types = ( Text.Whitespace, Text.Whitespace.Newline, Comment.Single, Comment.Multiline )

    num_tokens = len(tokens)
    for i, token in enumerate(tokens):
    	if token.ttype not in ignored_types:
            last = i + 1 == num_tokens
            horizontal_node = '├' if not last else '└'
            vertical_node = '│' if not last else '  '

            print('{left}{repr}'.format(left=left + horizontal_node, repr=repr_token(token)))
            if isinstance(token, TokenList):
                if token.is_group:
                    print_tree(token.tokens, left=left + vertical_node)


def main() -> int:
    """Main of the sqltree tool.

    :return: Exit status. Returns 0 on success.
    """
    arg_parser = argparse.ArgumentParser(
        description='Print parsed SQL statement as a tree.')

    arg_parser.add_argument('-E', '--encoding', metavar='encoding',
                            default=locale.getpreferredencoding(),
                            help='Input charset (default is OS-preferred value)')
    arg_parser.add_argument('filename', help='Text filename which contains SQL statements.')

    args = arg_parser.parse_args()

    if args.filename == '-':
        text = sys.stdin.read()
    else:
        with open(args.filename, 'r', encoding=args.encoding) as file:
            text = file.read()

    for statement, line in parsed_statement_and_coords(text):
        print('{0}:{1}'.format(os.path.relpath(args.filename), line))
        print_tree(statement.tokens)
        print()

    return 0


if __name__ == '__main__':
    sys.exit(main())
