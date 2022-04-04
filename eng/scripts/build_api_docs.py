#!/usr/bin/python3

"""
build_api_docs.py

Script to generate Jazzy documentation.
"""

import glob
import json
import logging
import os
import re
import subprocess
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

def _run(command):
    process = subprocess.Popen(command.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    return (stdout.decode("utf-8"), stderr.decode("utf-8"))

#    done
#    echo "Generating index"
#    erb jazzy/index.html.erb > build/jazzy/index.html
#  else
#    index=n
#    for lib in "$@"; do
#      if [ -f "jazzy/$lib.yml" ]; then
#        index=y
#        echo "Generating API docs for $lib"
#        jazzy --config "jazzy/$lib.yml"
#      else
#        echo "warning: No Jazzy configuration for $lib was found, it will be skipped."
#      fi
#    done
#
#    if [ "$index" = "y" ]; then
#      echo "Generating index"
#      erb jazzy/index.html.erb > build/jazzy/index.html


if __name__ == '__main__':
    usage = f'usage: python {os.path.split(__file__)[1]} ( NAME ... | all)'
    args = sys.argv[1:]
    if not args:
        _log_error_and_quit(usage)
    if "-h" in args or "--help" in args:
        print(usage)
        sys.exit(1)
    if "all" in args:
        paths = glob.glob(os.path.join("jazzy", "*.yml"))
    else:
        paths = [f"jazzy/{x}.yml" for x in args]
    for path in paths:
        try:
            logging.info(f"Generating docs for: {path}")
            if not os.path.exists(path):
                logging.warning(f"No config found for {path}. Skipping.")
                continue
            stdout, stderr = _run(f"jazzy --config {path}")
            logging.info(stdout)
            if "RuntimeError" in stderr:
                logging.error(f"Error generating docs.\n{stderr}")
        except Exception as err:
            if "No such file or directory: 'jazzy'" in str(err):
                logging.error("error: Jazzy not installed. Download from https://github.com/realm/jazzy")
            else:
                logging.error(f"error: {err}")
    sys.exit(0)
