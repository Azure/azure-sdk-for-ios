#!/usr/bin/python3

"""
build_api_docs.py

Script to generate Jazzy documentation.
"""

import datetime
import glob
from jinja2 import Template
import logging
import os
import subprocess
import sys
import yaml
import time


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

def _run(command, **kwargs):
    process = subprocess.Popen(command.split() if not kwargs.get("shell", False) else command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, **kwargs)
    stdout, stderr = process.communicate()
    return (stdout.decode("utf-8"), stderr.decode("utf-8"))

def _clone_github_repo(path, *, ref = None, pod_install = True):
    # clone the repo into the build folder so it can easily be removed
    repo_name = os.path.split(path)[-1]
    branch_arg = f"--branch {ref}" if ref else ""
    clone_dir = f"build/{repo_name}"
    if os.path.exists(clone_dir):
        _run(f"rm -rf {clone_dir}")

    _run(f"git clone {path} build/{repo_name} --depth 1 {branch_arg} --single-branch")

    if pod_install:
        try:
            # find the podfile and run pod install
            podfile_path = glob.glob(os.path.abspath(os.path.join(".", "build", repo_name, "**", "Podfile")))[0]
            podfile_dir = os.path.split(podfile_path)[0]
            stdout, stderr = _run(f"pod install --project-directory={podfile_dir}")
            print(stdout)
        except:
            _log_warning("Podfile not found. Attempting to generate docs without pod install...")

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
            if not os.path.exists(path):
                logging.warning(f"No config found for {path}. Skipping.")
                continue
            with open(path, "r") as config_file:
                contents = yaml.safe_load(config_file)
                github_url = contents.get("github_url", None)
                ref = contents.get("ref", None)
                no_jazzy_mode = contents.get("no_jazzy_mode", None)
                no_jazzy_mode_pregenerated = True if no_jazzy_mode == "pre-generated" else False
                if not github_url.endswith("/azure-sdk-for-ios"):
                    print(f"Cloning repo: {github_url}...")
                    _clone_github_repo(path=github_url, ref=ref, pod_install=(not no_jazzy_mode_pregenerated))

            print(f"Generating docs for: {path}...")
            if no_jazzy_mode is None:
                stdout, stderr = _run(f"jazzy --config {path}")
            elif no_jazzy_mode_pregenerated:
                time.sleep(5)
                output = "build/" + contents.get("output", None)
                input_dir = "build/" + os.path.split(github_url)[-1]
                print(f"Copying {input_dir} to {output}...")
                stdout, stderr = _run(f"mkdir -p {output}")
                stdout, stderr = _run(f"mv {input_dir}/* {output}", shell=True)

            else:
                logging.error(f"no_jazzy_mode specified but don't know how to handle '{no_jazzy_mode}'.")
            if "RuntimeError" in stderr:
                logging.error(f"==BEGIN STDERR==.\n{stderr}\n==END STDERR==\nError generating docs.")
            else:
                print(stdout)
        except Exception as err:
            if "No such file or directory: 'jazzy'" in str(err):
                logging.error("error: Jazzy not installed. Download from https://github.com/realm/jazzy")
            else:
                logging.error(f"error: {err}")

    # load template and render index
    print("Generating index...")
    module_names = sorted([os.path.split(x)[-1][:-4] for x in paths])
    index_template_path = os.path.abspath(os.path.join(".", "jazzy", "index_template.html"))
    with open(index_template_path) as infile:
        template = Template(infile.read())
        rendered = template.render(
            copyright_year=datetime.date.today().year,
            navigation=module_names
        )

    # write index to file
    index_path = os.path.abspath(os.path.join(".", "jazzy", "index.html"))
    with open(index_path, "w") as outfile:
        outfile.write(rendered)
    sys.exit(0)
