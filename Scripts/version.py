#!/usr/bin/python3

"""
versions.py

Various scripts dealing with versioning
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
Returns a dictionary of Modules and versions from the Xcodeproj files
"""
def _get_xcodeproj_versions():
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
def _get_podspec_versions():
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
def _get_spm_modules():
    with open('Package.swift', mode='r') as f:
        data = f.read()
    modules = re.findall(r'library\(\s*name:\s*"([a-zA-Z]+)"', data)
    return modules


"""
Ensures that all Xcodeproj files, Podspecs and Package.swift have the same versions.
"""
def verify(argv):
    xcodeproj_versions = _get_xcodeproj_versions()
    if len(set(xcodeproj_versions.values())) != 1:
        _log_error_and_quit(f'Incompatible versions within Xcodeproj files: {xcodeproj_versions}')
    xcodeproj_version = list(set(xcodeproj_versions.values()))[0]

    podspec_versions = _get_podspec_versions()
    if len(set(podspec_versions.values())) != 1:
        _log_error_and_quit(f'Incompatible versions within Podspec files: {podspec_versions}')
    podspec_version = list(set(podspec_versions.values()))[0]

    if xcodeproj_version != podspec_version:
        _log_error_and_quit(f'Podspec versions {podspec_versions} doesn\'t match Xcodeproj versions {xcodeproj_versions}')

    swift_modules = _get_spm_modules()
    for module in swift_modules:
        if module not in podspec_versions:
            _log_error_and_quit(f'Module {module} found in Package.swift but does not have a podspec file.')

    # warn if there are modules that are available via CocoaPods but not SPM
    for module in podspec_versions.keys():
        if module not in swift_modules:
            logging.warning(f'Module {module} has a podspec but is not in Package.swift. It cannot be acquired via SPM.')

    # warn for modules which are not released in any form
    for module in xcodeproj_versions.keys():
        if module not in swift_modules and module not in podspec_versions:
            logging.warning(f'Module {module} is on the master branch but not available via any release mechanism.')

    print('Package.swift, podspecs and Xcodeproj files are consistent.')
    sys.exit(0)


"""
Outputs the current version of the Azure SDK for iOS.
"""
def current(argv):
    xcodeproj_versions = _get_xcodeproj_versions()
    if len(set(xcodeproj_versions.values())) != 1:
        _log_error_and_quit(f'Incompatible versions within Xcodeproj files: {xcodeproj_versions}')
    xcodeproj_version = list(set(xcodeproj_versions.values()))[0]

    # all checks successful, return version
    print(xcodeproj_version)
    sys.exit(0)


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


"""
Updates the current version across Xcodeproj files, Package.swift, Jazzy files, and Podspecs.
"""
def update(argv):

    if len(argv) != 2:
        _log_error_and_quit(f'usage: {__file__} update old_version new_version')

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
    cwd = os.getcwd()
    if os.path.basename(cwd) != 'azure-sdk-for-ios':
        _log_error_and_quit('This script must be run from the root of the azure-sdk-for-ios repo')

    usage = f'usage: {__file__} {{verify|update|current}} [ARGS]'
    try:
        command = sys.argv[1].strip().lower()
        method = globals().get(command)
        if not method:
            _log_error_and_quit(usage)
        method(sys.argv[2:])
    except IndexError:
        _log_error_and_quit(usage)
