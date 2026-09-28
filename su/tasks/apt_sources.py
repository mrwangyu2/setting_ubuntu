"""Configure the apt archive mirror.

>= 24.04 gets the deb822 format at /etc/apt/sources.list.d/ubuntu.sources and
the legacy /etc/apt/sources.list is neutralised. <= 22.04 keeps the classic
one-line format. The release codename is read from /etc/os-release, so there
is no per-release file to maintain.
"""

from .. import apt, fileutil, log
from ..mirrors import APT_MIRRORS

NAME = "apt-sources"
DESC = "Point apt at a mirror (deb822 on >=24.04, classic format on <=22.04)"

SIGNED_BY = "/usr/share/keyrings/ubuntu-archive-keyring.gpg"
COMPONENTS = "main restricted universe multiverse"
DEB822_PATH = "/etc/apt/sources.list.d/ubuntu.sources"
CLASSIC_PATH = "/etc/apt/sources.list"


def _deb822(uri, codename):
    suites = "%s %s-updates %s-backports" % (codename, codename, codename)
    return (
        "Types: deb\n"
        "URIs: %s\n"
        "Suites: %s\n"
        "Components: %s\n"
        "Signed-By: %s\n"
        "\n"
        "Types: deb\n"
        "URIs: %s\n"
        "Suites: %s-security\n"
        "Components: %s\n"
        "Signed-By: %s\n"
    ) % (
        uri,
        suites,
        COMPONENTS,
        SIGNED_BY,
        uri,
        codename,
        COMPONENTS,
        SIGNED_BY,
    )


def _classic(uri, codename):
    lines = []
    for suite in (
        codename,
        codename + "-updates",
        codename + "-backports",
        codename + "-security",
    ):
        lines.append("deb %s %s %s" % (uri, suite, COMPONENTS))
    return "\n".join(lines) + "\n"


def _disable_legacy(sh):
    content = fileutil.read(CLASSIC_PATH)
    if not content:
        return
    active = [
        line
        for line in content.splitlines()
        if line.strip() and not line.strip().startswith("#")
    ]
    if not active:
        log.skip("legacy sources.list already inactive")
        return
    fileutil.write(
        sh,
        CLASSIC_PATH,
        "# Disabled by setting_ubuntu; apt now reads %s\n" % DEB822_PATH,
        sudo=True,
    )


def run(ctx):
    sh = ctx.sh
    uri = APT_MIRRORS[ctx.options.mirror]
    codename = ctx.system.codename
    if not codename:
        raise RuntimeError("could not detect Ubuntu codename from /etc/os-release")

    if ctx.system.is_deb822:
        fileutil.write(sh, DEB822_PATH, _deb822(uri, codename), sudo=True, protect=True)
        _disable_legacy(sh)
    else:
        fileutil.write(sh, CLASSIC_PATH, _classic(uri, codename), sudo=True, protect=True)

    apt.update(sh, force=True)
