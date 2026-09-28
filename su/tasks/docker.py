"""Install Docker Engine.

Uses the official Docker repo when it has a build for this release, and
falls back to the distro's docker.io for releases Docker has not caught up
with yet (a fresh LTS tends to lag for a few weeks). Once either flavour is
installed the task is a no-op, so the fallback does not retry forever.
"""

from .. import apt, log
from ..runner import CommandError

NAME = "docker"
DESC = "Install Docker Engine (official repo, docker.io fallback)"

KEYRING = "/usr/share/keyrings/docker-archive-keyring.gpg"
KEY_URL = "https://download.docker.com/linux/ubuntu/gpg"
CE_PACKAGES = [
    "docker-ce",
    "docker-ce-cli",
    "containerd.io",
    "docker-buildx-plugin",
    "docker-compose-plugin",
]
FALLBACK_PACKAGE = "docker.io"


def _ensure_group(sh, user):
    groups = sh.capture(["id", "-nG", user]) or ""
    if "docker" in groups.split():
        log.ok("user %s already in the docker group" % user)
        return
    sh.run(["groupadd", "-f", "docker"], sudo=True, check=False)
    sh.run(["usermod", "-aG", "docker", user], sudo=True)
    log.warn("run 'newgrp docker' or log back in for the docker group to apply")


def _already_installed(sh):
    return apt.installed(sh, "docker-ce") or apt.installed(sh, FALLBACK_PACKAGE)


def run(ctx):
    sh = ctx.sh
    system = ctx.system
    if _already_installed(sh):
        log.ok("docker already installed")
        _ensure_group(sh, system.user)
        return

    apt.ensure_installed(sh, ["ca-certificates", "curl", "gnupg"])
    repo = "deb [arch=%s signed-by=%s] https://download.docker.com/linux/ubuntu %s stable\n" % (
        system.deb_arch,
        KEYRING,
        system.codename,
    )
    apt.ensure_signed_repo(sh, "docker.list", KEY_URL, KEYRING, repo)

    try:
        apt.update(sh, force=True)
        apt.ensure_installed(sh, CE_PACKAGES)
    except CommandError:
        log.warn(
            "no Docker CE packages for %s; falling back to %s"
            % (system.codename or system.version, FALLBACK_PACKAGE)
        )
        apt.ensure_repo(
            sh,
            "docker.list",
            "# Disabled by setting_ubuntu: no Docker CE build for %s\n"
            % (system.codename or system.version),
        )
        apt.update(sh, force=True)
        apt.ensure_installed(sh, [FALLBACK_PACKAGE])

    _ensure_group(sh, system.user)
