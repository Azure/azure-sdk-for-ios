#!/usr/bin/python3

"""
util.py

Utility scripts to simplify bash scripting
"""

import glob
import json
import logging
import os
import re
import sys

def _log_error_and_quit(msg, out = None, err = None, code = 1):
    """ Log an error message and exit. """
    warning_color = '\033[91m'
    end_color = '\033[0m'
    if err:
        logging.error(f'{err}')
    elif out:
        logging.error(f'{out}')
    logging.error(f'{warning_color}{msg} ({code}){end_color}')
    sys.exit(code)

"""
Outputs the path to projects that have podspec files
"""
def list_podspecs(*args):
    pattern = os.path.join(ROOT, 'sdk', '**', '*.podspec.json')
    podspec_files = glob.glob(pattern, recursive=True)
    for path in podspec_files:
        print(path)

"""
Outputs the path to projects that have Package.swift files
"""
def list_swift_packages(*args):
    pattern = os.path.join(ROOT, 'sdk', '**', 'Package.swift')
    podspec_files = glob.glob(pattern, recursive=True)
    for path in podspec_files:
        directory, _ = os.path.split(os.path.normpath(path))
        print(directory)


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))

if __name__ == '__main__':

    usage = f'usage: {__file__} {{list_podspecs|list_swift_packages}}'
    try:
        command = sys.argv[1].strip().lower()
        method = globals().get(command)
        if not method:
            _log_error_and_quit(usage)
        method(sys.argv[2:])
    except IndexError:
        _log_error_and_quit(usage)
