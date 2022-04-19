#!/usr/bin/python3

"""
build_api_docs.py

Script to generate Jazzy documentation.
"""

import glob
import logging
import os
import subprocess
import sys
import yaml


logging.getLogger().setLevel(logging.WARNING)


def _log_error_and_quit(msg, out = None, err = None, code = 1):
    """ Log an error message and exit. """
    warning_color = "\033[91m"
    end_color = "\033[0m"
    if err:
        logging.error(f"{err}")
    elif out:
        logging.error(f"{out}")
    logging.error(f"{warning_color}{msg} ({code}){end_color}")
    sys.exit(code)

def _log_warning(msg):
    """ Log a warning message. """
    warning_color = "\033[93m"
    end_color = "\033[0m"
    logging.warning(f"{warning_color}{msg}{end_color}")

def _run(command):
    process = subprocess.Popen(command.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    return (stdout.decode("utf-8"), stderr.decode("utf-8"))

def _clone_github_repo(path):

    repo_name = os.path.split(path)[-1]

    # clone repo
    _run(f"git clone {path} {repo_name}")

    # find the podfile and run pod install
    try:
        podfile_path = glob.glob(os.path.join(".", repo_name, "**", "Podfile"))[0]
        _run(f"pod install {podfile_path}")
    except:
        _log_warning("Unable to find Podfile. Attempting to generate docs without pod install...")

if __name__ == "__main__":
    usage = f"usage: python {os.path.split(__file__)[1]} ( NAME ... | all)"
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
            print(f"Generating docs for: {path}...")
            if not os.path.exists(path):
                logging.warning(f"No config found for {path}. Skipping.")
                continue
            with open(path, "r") as config_file:
                contents = yaml.safe_load(config_file)
                github_url = contents.get("github_url", None)
                if not github_url.endswith("azure-sdk-for-ios"):
                    _clone_github_repo(github_url)

            stdout, stderr = _run(f"jazzy --config {path}")
            if "RuntimeError" in stderr:
                logging.error(f"==BEGIN STDERR==.\n{stderr}\n==END STDERR==\nError generating docs.")
            else:
                print(stdout)
        except Exception as err:
            if "No such file or directory: 'jazzy'" in str(err):
                logging.error("error: Jazzy not installed. Download from https://github.com/realm/jazzy")
            else:
                logging.error(f"error: {err}")
    print("Generating index...")
    # TODO: Must run a Python jinja template to generate the index.
    #stdout, stderr = _run(f"erb jazzy/index.html.erb > build/jazzy/index.html")
    sys.exit(0)
