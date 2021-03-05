#!/usr/bin/python3

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
Returns a dictionary of Modules and versions from the Xcodeproj files
"""
def get_xcodeproj_versions():
    versions = {}
    proj_files = glob.glob(r'sdk/*/*/*.xcodeproj/project.pbxproj')
    for path in proj_files:
        module_name = re.search(r'/([a-zA-Z]+)\.xcodeproj', path).groups()[0]
        with open(path, mode='r') as f:
            lines = [l for l in f.readlines() if 'MARKETING_VERSION' in l]
        for line in lines:
            version = re.search(r'"([^"]+)"', line).groups()[0]
            if module_name in versions and versions[module_name] != version:
                # throws error if multiple different versions are found
                message = f'Found multiple versions for {module_name}: {version} and {versions[module_name]}'
                _log_error_and_quit(message)
            else:
                versions[module_name] = version
    return versions


"""
Returns a dictionary of Modules and versions from the podspec files
"""
def get_podspec_versions():
    versions = {}
    podspec_files = glob.glob(r'*.podspec.json')
    for path in podspec_files:
        module_name, _ = path.split('.', maxsplit=1)
        with open(path, mode='r') as f:
            data = json.loads(f.read())
            versions[module_name] = data['version']
    return versions


"""
Returns a list of Modules defined in Package.swift
"""
def get_spm_modules():
    with open('Package.swift', mode='r') as f:
        data = f.read()
    modules = re.findall(r'library\(\s*name:\s*"([a-zA-Z]+)"', data)
    return modules


def main(argv):
    cwd = os.getcwd()
    if os.path.basename(cwd) != 'azure-sdk-for-ios':
        _log_error_and_quit('This script must be run from the root of the azure-sdk-for-ios repo')

    xcodeproj_versions = get_xcodeproj_versions()
    if len(set(xcodeproj_versions.values())) != 1:
        _log_error_and_quit(f'Incompatible versions within Xcodeproj files: {xcodeproj_versions}')
    xcodeproj_version = list(set(xcodeproj_versions.values()))[0]

    # all checks successful, return version
    print(xcodeproj_version)
    sys.exit(0)


if __name__ == '__main__':
    main(sys.argv[1:])
