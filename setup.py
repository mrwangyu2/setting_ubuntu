#!/usr/bin/env python3
"""Entry point. Kept deliberately thin so `./setup.py <command>` works
directly, without installing the package.

    ./setup.py list
    ./setup.py plan
    ./setup.py run
    ./setup.py run apt-sources,base-packages
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from su.cli import main  # noqa: E402

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
