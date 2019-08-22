#!/usr/bin/python3

import sys
import os
import shutil
from subprocess import check_call


BASE_DIR = os.path.abspath(os.path.dirname(__file__))
DOTBOT_DIR = os.path.join(BASE_DIR, "dotbot")
DOTBOT_BIN = os.path.join(DOTBOT_DIR, "bin", "dotbot")


def dotbot(directory, config, args=None):
    cmd = [sys.executable, DOTBOT_BIN, "-d", directory, "-c", config]
    if args:
        cmd.extend(args)
    check_call(cmd, cwd=BASE_DIR)


def main():
    if sys.version_info < (3, 5):
        sys.exit("Require Python 3.5 or newer")

    git = shutil.which("git")
    if not git:
        sys.exit("Require Git")

    check_call([git, "-C", DOTBOT_DIR, "submodule",
                "sync", "--quiet", "--recursive"])
    check_call([git, "-C", BASE_DIR, "submodule",
                "update", "--init", "--recursive"])

    dotbot(BASE_DIR, "install.conf.yaml")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
