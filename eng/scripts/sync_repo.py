#!/usr/bin/python3

"""
sync_repo.py

Script to copy code from mono-repo to read-only clone.
"""

import errno
import glob
import json
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
            shutil.copy2(src, dest)
        else:
            _log_error_and_quit(f'Error copying folder: {err}')

"""
Copies code from a relative path in the mono-repo to the read-only repo.
"""
def main(argv):
    usage = f'usage: {__file__} TARGET_SDK'

    if len(argv) != 1:
        _log_error_and_quit(f'usage: {__file__} TARGET_SDK')

    target = argv[0]

    try:
        source_path = os.path.abspath(os.path.join(glob.glob(f'sdk/**/{target}.podspec.json', recursive=True)[0], ".."))
        if not os.path.exists(source_path):
            _log_error_and_quit(f'Source path does not exist: {source_path}')
    except IndexError:
        _log_error_and_quit(f'Could not find {target}.podspec.json')

    dest_path = os.path.abspath(os.path.join(ROOT, '..', f'SwiftPM-{target}'))
    if not os.path.exists(dest_path):
        _log_error_and_quit(f'Destination path does not exist: {dest_path}')

    # clear the files to ensure renames are correctly picked up.
    for obj in os.listdir(dest_path):
        # skip deleting .git
        if obj in [".git"]:
            continue
        obj_path = os.path.join(dest_path, obj)
        if os.path.isfile(obj_path):
            os.unlink(obj_path)
        else:
            shutil.rmtree(obj_path)

    # copy the subfolder to the root of the SwiftPM repo
    _copy(source_path, dest_path)

    # copy the LICENSE, CCONTRIBUTING.md, and .gitignore files
    for fname in ["LICENSE", "CONTRIBUTING.md", ".gitignore"]:
        _copy(os.path.join(ROOT, fname), os.path.join(dest_path, fname))

    print(f'Successfully copied {target}:')
    print(f'  source: {source_path}')
    print(f'  dest: {dest_path}')
    sys.exit(0)


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))

if __name__ == '__main__':
    main(sys.argv[1:])
