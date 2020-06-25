#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# -------------------------------------------------------------------------
# Copyright 2019-2020 T2T Inc. All rights reserved.
#
# FILE:
#     kfx.py    (KiField Extension script)
#
# DESCRIPTION:
#     python script for post processing on the TSV/CSV extracted by KiField. 
#
#
# REVISION HISTORY
#     2020/06/22, yagamy, initial version.
#
import re
import sys
import subprocess
import argparse
from pathlib import Path
import fileinput

debugging = False

##
# Run this script with python 3.6+
#
if not (sys.version_info.major == 3 and sys.version_info.minor >= 6):
    print("Python 3.6 or higher is required.")
    print("You are using Python {}.{}.".format(sys.version_info.major, sys.version_info.minor))
    sys.exit(1)


def DEBUG(*args, **kwargs):
    if debugging:
        print(*args, file=sys.stderr, **kwargs)

def ERR(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def _run_refs(path, board=None, tab=False):
    DEBUG(f'running `refs` subcommand, path={path}, board={board}, tab={tab}')
    fp = sys.stdin.readlines() if path == '-' else fileinput.input(files=[path])
    p1 = re.compile("^[A-Z]+[0-9]+")
    p2 = re.compile("^[A-Z]+")
    p3 = re.compile("[0-9]+")
    for line in fp:
        line = line.rstrip()
        tokens = line.split('\t') if tab else line.split(',')
        refs = tokens[0]
        if p1.match(refs):
            designator = p2.search(refs).group(0)
            rid = p3.search(refs).group(0)
            tokens = [board, designator, rid, *tokens] if board else [designator, rid, *tokens]
            separator = '\t' if tab else ','
            print(separator.join(tokens))
    return 0


def _build_parser():
    ###
    # Inspired by: https://medium.com/@dboyliao/python-%E8%B6%85%E5%A5%BD%E7%94%A8%E6%A8%99%E6%BA%96%E5%87%BD%E5%BC%8F%E5%BA%AB-argparse-part-2-b5a178f08813
    #
    parser = argparse.ArgumentParser()
    subcmd = parser.add_subparsers(dest='subcmd', help='subcommands', metavar='SUBCOMMAND')
    subcmd.required = True

    refs_parser = subcmd.add_parser('refs', help='extract designator/index from Refs field')
    refs_parser.add_argument('path',
                                help='path of the given CSV file, either space or tab separated',
                                metavar='CSV')
    refs_parser.add_argument("--board", metavar="", dest="board", default=None, help="Board name")
    refs_parser.add_argument('--tab', dest='tab', action='store_true')
    refs_parser.add_argument('--verbose', dest='verbose', action='store_true')
    return parser



def main():
    parser = _build_parser()
    args = parser.parse_args()

    global debugging
    debugging = True if (args.verbose) else False

    if args.subcmd == 'refs':
        return _run_refs(args.path, args.board, args.tab)
    elif args.subcmd == 'man':
        return 0
    else:
        return 0




if __name__ == '__main__':
    ret = main()
    sys.exit(ret)
