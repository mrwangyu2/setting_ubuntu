"""Install the common apt package set from resources/lists/base.txt."""

from .. import apt, fileutil

NAME = "base-packages"
DESC = "Install the common apt package set"


def run(ctx):
    packages = fileutil.read_list(ctx.resource("lists/base.txt"))
    apt.ensure_installed(ctx.sh, packages)
