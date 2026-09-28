"""Install Syncthing from its official apt repository."""

from .. import apt

NAME = "syncthing"
DESC = "Install Syncthing and enable syncthing@<user>"

KEYRING = "/usr/share/keyrings/syncthing-archive-keyring.gpg"
KEY_URL = "https://syncthing.net/release-key.gpg"


def run(ctx):
    sh = ctx.sh
    system = ctx.system
    repo = "deb [signed-by=%s] https://apt.syncthing.net/ syncthing stable\n" % KEYRING
    apt.ensure_signed_repo(sh, "syncthing.list", KEY_URL, KEYRING, repo)
    apt.update(sh)
    apt.ensure_installed(sh, ["syncthing"])
    sh.run(["systemctl", "enable", "--now", "syncthing@%s" % system.user], sudo=True)
