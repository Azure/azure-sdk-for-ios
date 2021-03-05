#!/usr/bin/python3

import glob
import json
import logging
import os
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


def _update_file(path, old, new):
    with open(path, mode='r') as f:
        data = f.read()
    data = data.replace(old, new)
    with open(path, mode='w') as f:
        f.write(data)

"""
Updates the version, source and dependency info for podspec files
"""
def _update_podspecs(old, new):
    podspec_files = glob.glob(r'*.podspec.json')
    module_names = set([name.split('.')[0] for name in podspec_files])
    for path in podspec_files:
        with open(path, 'r') as f:
            data = json.loads(f.read())

        data['version'] = new
        source = data.get('source', None)
        if source:
            if source.get('http', None):
                source['http'] = source['http'].replace(old, new)
            if source.get('tag', None):
                source['tag'] = new

        dependencies = data.get('dependencies', None)
        for key, vals in (dependencies or {}).items():
            if key in module_names:
                dependencies[key] = [val.replace(old, new) for val in vals]

        with open(path, 'w') as f:
            f.write(json.dumps(data, indent=2, ensure_ascii=False))


"""
Updates the marketing version key for all Xcodeproj files
"""
def _update_xcodeproj(old, new):
    xcodeproj_files = glob.glob(r'sdk/*/*/*.xcodeproj/project.pbxproj')
    for path in xcodeproj_files:
        with open(path, 'r') as f:
            data = f.readlines()

        with open(path, 'w') as f:
            for line in data:
                if "MARKETING_VERSION" in line:
                    f.write(line.replace(old, new))
                else:
                    f.write(line)


def main(argv):
    cwd = os.getcwd()
    if os.path.basename(cwd) != 'azure-sdk-for-ios':
        _log_error_and_quit('This script must be run from the root of the azure-sdk-for-ios repo')

    if len(argv) != 2:
        _log_error_and_quit(f'usage: python3 {__file__} old_version new_version')

    old = argv[0]
    new = argv[1]

    # TODO: maybe (?) update CHANGELOG.md

    files_to_update = [
        'README.md',
        'eng/ignore-links.txt'
    ]
    files_to_update += glob.glob(r'jazzy/*.yml')
    for path in files_to_update:
        _update_file(path, old, new)
    _update_podspecs(old, new)
    _update_xcodeproj(old, new)


if __name__ == '__main__':
    main(sys.argv[1:])
