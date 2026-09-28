"""Install Node.js from NodeSource.

18.04 keeps Node 16 (bionic's glibc is too old for NodeSource's 18.x
builds); everything newer gets Node 22. The repo is declared with signed-by
instead of the deprecated "curl | sudo bash" flow.
"""

from .. import apt

NAME = "nodejs"
DESC = "Install Node.js from the NodeSource repository"

KEYRING = "/usr/share/keyrings/nodesource.gpg"
KEY_URL = "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key"


def _major(system):
    return "16" if system.version_tuple < (20, 0) else "22"


def run(ctx):
    sh = ctx.sh
    major = _major(ctx.system)
    repo = "deb [signed-by=%s] https://deb.nodesource.com/node_%s.x nodistro main\n" % (
        KEYRING,
        major,
    )
    apt.ensure_signed_repo(sh, "nodesource.list", KEY_URL, KEYRING, repo)
    apt.update(sh)
    apt.ensure_installed(sh, ["nodejs"])
