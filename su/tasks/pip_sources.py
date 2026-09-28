"""Write the pip mirror config into the target user's home (directly, never
through sudo, so the file stays owned by that user)."""

import os

from .. import fileutil
from ..mirrors import PYPI_MIRRORS

NAME = "pip-sources"
DESC = "Point pip at a PyPI mirror"


def run(ctx):
    key = ctx.options.pypi_mirror or ctx.options.mirror
    if key not in PYPI_MIRRORS:
        key = "official"
    index, host = PYPI_MIRRORS[key]

    content = "[global]\nindex-url = %s\n" % index
    if host:
        content += "[install]\ntrusted-host = %s\n" % host

    path = os.path.join(ctx.system.home, ".config/pip/pip.conf")
    fileutil.write(ctx.sh, path, content)
