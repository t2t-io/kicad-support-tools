#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# -------------------------------------------------------------------------
# Copyright 2019-2020 T2T Inc. All rights reserved.
#
# FILE:
#     ioc.py    (Process STM32CubeIDE setting file: ioc, and generate csv)
#
# DESCRIPTION:
#     python script for post processing on the TSV/CSV extracted by KiField. 
#
#
# REVISION HISTORY
#     2021/08/11, yagamy, initial version.
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

def show_segment(segments, index):
    lines = segments[index].split('\n')
    DEBUG(f's[{index}] =>\n{lines}\n----\n')

def _run_txt2csv(path, view=None, tab=False):
    DEBUG(f'running `refs` subcommand, path={path}, view={view}, tab={tab}')
    buffer = sys.stdin.read() if path == '-' else open(path).read()
    text = str(buffer)
    segments = text.split('\n\n\n\n')
    DEBUG(f'segments => {len(segments)}')
    # show_segment(segments, 0)
    # show_segment(segments, 1)
    # show_segment(segments, 2)
    # show_segment(segments, 3)
    # show_segment(segments, 4)
    separator = '\t' if tab else ','
    data = segments[1] if view == "peripheral" else segments[3]
    lines = data.split('\n')
    xs = [ (x.split('\t')) for x in lines ]
    xs = [ (separator.join(x)) for x in xs ]
    xs = '\n'.join(xs)
    print(xs)
    return 0


def _build_parser():
    ###
    # Inspired by: https://medium.com/@dboyliao/python-%E8%B6%85%E5%A5%BD%E7%94%A8%E6%A8%99%E6%BA%96%E5%87%BD%E5%BC%8F%E5%BA%AB-argparse-part-2-b5a178f08813
    #
    parser = argparse.ArgumentParser()
    subcmd = parser.add_subparsers(dest='subcmd', help='subcommands', metavar='SUBCOMMAND')
    subcmd.required = True

    refs_parser = subcmd.add_parser('txt2csv', help='extract one CSV segment from the TEXT report generated from IOC file')
    refs_parser.add_argument('path',
                                help='path of the given Text report',
                                metavar='TXT')
    refs_parser.add_argument("--view", metavar="", dest="view", default=None, help="peripheral view or pin view")
    refs_parser.add_argument('--tab', dest='tab', action='store_true')
    refs_parser.add_argument('--verbose', dest='verbose', action='store_true')
    return parser



def main():
    parser = _build_parser()
    args = parser.parse_args()

    global debugging
    debugging = True if (args.verbose) else False
    

    if args.subcmd == 'txt2csv':
        return _run_txt2csv(args.path, args.view, args.tab)
    elif args.subcmd == 'man':
        return 0
    else:
        print(f'args.subcmd = {args.subcmd}, that is unsupported')
        return 0




if __name__ == '__main__':
    ret = main()
    sys.exit(ret)
