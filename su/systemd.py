"""systemd unit installation, kept separate from plain file operations."""

from . import fileutil


def is_active(sh, unit):
    return sh.succeeds(["systemctl", "is-active", "--quiet", unit], sudo=True)


def ensure_unit(sh, name, content, enable=True, start=True):
    """Install a systemd unit and make sure it is enabled and running."""
    path = "/etc/systemd/system/%s" % name
    changed = fileutil.write(sh, path, content, sudo=True, backup=False)
    if changed:
        sh.run(["systemctl", "daemon-reload"], sudo=True)
    if enable:
        sh.run(["systemctl", "enable", name], sudo=True, check=False)
    if start and (changed or not is_active(sh, name)):
        sh.run(["systemctl", "restart", name], sudo=True, check=False)
