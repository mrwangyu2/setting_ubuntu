"""Install the gdu disk usage tool.

Skips when already installed; pass --upgrade to refresh to the latest
release. Architecture-aware.
"""

import os
import shutil
import tempfile

from .. import log

NAME = "gdu"
DESC = "Install the gdu disk usage tool (--upgrade to refresh)"

DEST = "/usr/local/bin/gdu"
_ARCH = {"amd64": "amd64", "arm64": "arm64", "armhf": "armv7"}


def run(ctx):
    sh = ctx.sh
    system = ctx.system
    if os.path.exists(DEST) and not ctx.options.upgrade:
        log.ok("gdu already installed (use --upgrade to refresh)")
        return

    arch = _ARCH.get(system.deb_arch)
    if not arch:
        raise RuntimeError("unsupported architecture for gdu: %s" % system.arch)

    tmp = tempfile.mkdtemp()
    try:
        url = (
            "https://github.com/dundee/gdu/releases/latest/download/"
            "gdu_linux_%s.tgz" % arch
        )
        sh.run(["curl", "-fL", url, "-o", os.path.join(tmp, "gdu.tgz")])
        sh.run(["tar", "-xzf", os.path.join(tmp, "gdu.tgz"), "-C", tmp])
        sh.run(["install", "-m", "0755", os.path.join(tmp, "gdu_linux_%s" % arch), DEST], sudo=True)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
