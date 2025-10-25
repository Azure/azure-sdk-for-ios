#!/usr/bin/python3

"""
version.py

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


def _log_warning(msg):
    """ Log a warning message. """
    warning_color = '\033[93m'
    end_color = '\033[0m'
    logging.warning(f'{warning_color}{msg}{end_color}')


"""
Returns a dictionary of Modules and versions from the Xcodeproj files
"""
def _get_xcodeproj_versions():
    versions = {}
    pattern = os.path.join(ROOT, 'sdk', '*', '*', '*.xcodeproj', 'project.pbxproj')
    proj_files = glob.glob(pattern)
    for path in proj_files:
        module_name = re.search(r'/([a-zA-Z]+)\.xcodeproj', path).groups()[0]
        with open(path, mode='r') as f:
            lines = [l for l in f.readlines() if 'MARKETING_VERSION' in l]
        for line in lines:
            # version may or may not be in double quotes in the file
            version_match = re.search(r'"([^"]+)"', line) or re.search(r'MARKETING_VERSION = ([^;]+);', line)
            version = version_match.groups()[0]
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
    pattern = os.path.join(ROOT, 'sdk', '**', '*.podspec.json')
    podspec_files = glob.glob(pattern, recursive=True)
    for path in podspec_files:
        module_name = os.path.basename(os.path.normpath(path.split('.', maxsplit=1)[0]))
        with open(path, mode='r') as f:
            data = json.loads(f.read())
            versions[module_name] = data['version']
    return versions


"""
Returns a list of modules which have a Package.swift file.
"""
def _get_spm_modules():
    modules = []
    pattern = os.path.join(ROOT, 'sdk', '**', 'Package.swift')
    package_files = glob.glob(pattern, recursive=True)
    for path in package_files:
        _, package_name = os.path.split(os.path.split(path)[0])
        modules.append(package_name)
    return modules


"""
Check Xcodeproj files, Podspecs and Package.swift for consistency.
"""
def verify(argv):
    xcodeproj_versions = _get_xcodeproj_versions()
    podspec_versions = _get_podspec_versions()
    swift_modules = _get_spm_modules()
    for module in swift_modules:
        if module not in podspec_versions:
            _log_error_and_quit(f'Module {module} found in Package.swift but does not have a podspec file.')

    # warn if there are modules that are available via CocoaPods but not SPM
    for module in podspec_versions.keys():
        if module not in swift_modules:
            _log_warning(f'Module {module} has a podspec but is not in Package.swift. It cannot be acquired via SPM.')
        if module not in xcodeproj_versions:
            _log_error_and_quit(f'Module {module} has a podspec but no Xcodeproj file.')
        elif podspec_versions[module] != xcodeproj_versions[module]:
            _log_error_and_quit(f'Module {module} has a podspec version {podspec_versions[module]} but an Xcodeproj version {xcodeproj_versions[module]}.')

    # warn for modules which are not released in any form
    for module in xcodeproj_versions.keys():
        if module not in swift_modules and module not in podspec_versions:
            _log_warning(f'Module {module} is on the master branch but not available via any release mechanism.')

    print('Package.swift, podspecs and Xcodeproj files are consistent.')
    sys.exit(0)


"""
Outputs the current version of the Azure SDK for iOS.
"""
def current(argv):
    if len(argv) != 1:
        _log_error_and_quit(f'usage: {__file__} current package_name')

    package_name = argv[0]

    xcodeproj_versions = _get_xcodeproj_versions()
    try:
        print(xcodeproj_versions[package_name])
    except KeyError:
        _log_error_and_quit(f'Package {package_name} not found.')
    sys.exit(0)


def _update_file(path, old, new):
    try:
        with open(path, mode='r') as f:
            data = f.read()
        data = data.replace(old, new)
        with open(path, mode='w') as f:
            f.write(data)
    except FileNotFoundError:
        _log_warning(f'File {path} not found. Skipping...')

"""
Updates the version, source and dependency info for specified podspec files
"""
def _update_podspecs(old, new, modules):
    podspecs = {}
    for path in glob.glob(r'sdk/*/*/*.podspec.json'):
        mod_name = re.search(r'/([a-zA-Z]+)\.podspec.*', path).groups()[0]
        podspecs[mod_name] = path

    for mod in modules:
        path = podspecs[mod]
        with open(path, 'r') as f:
            data = json.loads(f.read())

        name = data['name']
        data['version'] = new
        old_branch = f'{name}_{old}'
        new_branch = f'{name}_{new}'

        source = data.get('source', None)
        if source:
            if source.get('http', None):
                source['http'] = source['http'].replace(old_branch, new_branch)
            if source.get('tag', None):
                source['tag'] = new_branch

        dependencies = data.get('dependencies', None)
        for key, vals in (dependencies or {}).items():
            if key == mod:
                dependencies[key] = [val.replace(old, new) for val in vals]

        with open(path, 'w') as f:
            f.write(json.dumps(data, indent=2, ensure_ascii=False))


"""
Updates the marketing version key for specified Xcodeproj files
"""
def _update_xcodeproj(old, new, modules):
    xcodeprojs = {}
    for path in glob.glob(r'sdk/*/*/*.xcodeproj/project.pbxproj'):
        mod_name = re.search(r'/([a-zA-Z]+)\.xcodeproj.*', path).groups()[0]
        xcodeprojs[mod_name] = path

    for mod in modules:
        path = xcodeprojs[mod]
        with open(path, 'r') as f:
            data = f.readlines()

        with open(path, 'w') as f:
            for line in data:
                if "MARKETING_VERSION" in line:
                    f.write(line.replace(old, new))
                else:
                    f.write(line)


"""
Updates the README for specified modules
"""
def _update_readmes(old, new, modules):
    readmes = {}
    for path in glob.glob(r'sdk/*/*/README.md'):
        mod_name = re.search(r'/([a-zA-Z]+)/README\.md', path).groups()[0]
        readmes[mod_name] = path

    for mod in modules:
        path = readmes[mod]
        _update_file(path, old, new)


"""
Updates the current version across Xcodeproj files, Jazzy files, and Podspecs.
"""
def update(argv):

    if len(argv) < 3:
        _log_error_and_quit(f'usage: {__file__} update old_version new_version [package_name ...]')

    old = argv[0]
    new = argv[1]
    modules = argv[2:]

    if "." not in old or "." not in new:
        _log_error_and_quit(f'usage: {__file__} update old_version new_version [package_name ...]')

    files_to_update = []
    for mod in modules:
        files_to_update.append(f'jazzy/{mod}.yml')

    for path in files_to_update:
        _update_file(path, old, new)
    _update_podspecs(old, new, modules)
    _update_xcodeproj(old, new, modules)
    _update_readmes(old, new, modules)


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))

if __name__ == '__main__':

    usage = f'usage: {__file__} {{verify|update|current}} [ARGS]'
    try:
        command = sys.argv[1].strip().lower()
        method = globals().get(command)
        if not method:
            _log_error_and_quit(usage)
        method(sys.argv[2:])
    except IndexError:
        _log_error_and_quit(usage)
