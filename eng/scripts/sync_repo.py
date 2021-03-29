#!/usr/bin/python3

"""
sync_repo.py

Script to copy code from mono-repo to read-only clone.
"""

import errno
import logging
import os
import shutil
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

def _copy(src, dest):
    try:
        shutil.copytree(src, dest, dirs_exist_ok=True)
    except OSError as err:
        if err.errno == errno.ENOTDIR:
            shutil.move(src, dest)
        else:
            _log_error_and_quit(f'Error copying folder: {err}')

"""
Copies code from a relative path in the mono-repo to the read-only repo.
"""
def main(argv):
    usage = f'usage: {__file__} REL_PATH DEST_REPO'

    if len(argv) != 2:
        _log_error_and_quit(f'usage: {__file__} SOURCE_PATH DEST_REPO')

    source_path = os.path.abspath(os.path.join(ROOT, argv[0]))
    dest_path = os.path.abspath(os.path.join(ROOT, '..', argv[1]))

    if not os.path.exists(source_path):
        _log_error_and_quit(f'Source path does not exist: {source_path}')

    if not os.path.exists(dest_path):
        _log_error_and_quit(f'Destination path does not exist: {dest_path}')

    _copy(source_path, dest_path)
    print(f'Copied {source_path} to {dest_path}...')
    sys.exit(0)


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))

if __name__ == '__main__':
    main(sys.argv[1:])
