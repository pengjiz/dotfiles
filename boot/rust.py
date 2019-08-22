#!/usr/bin/python3

import sys
import shutil
from subprocess import check_call

# Toolchains to install
TOOLCHAINS = ["stable"]

# Setup toolchain
def setup_toolchain(rustup, toolchain):
    """Install toolchain and essential components."""
    check_call([rustup, "install", toolchain])

    for component in ["rust-src", "rustfmt", "clippy"]:
        check_call([rustup, "component", "add",
                    "--toolchain", toolchain,
                    component])


def main():
    rustup = shutil.which("rustup")

    if not rustup:
        sys.exit("Require rustup")

    check_call([rustup, "update"])

    for toolchain in TOOLCHAINS:
        setup_toolchain(rustup, toolchain)

    check_call([rustup, "default", "stable"])


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
