"""Detect the machine we are configuring.

Everything comes from /etc/os-release, which is reliable on 18.04 through
26.04 and lets us drop the hand-maintained list of release codenames.
"""

import os
import platform
import pwd

SUPPORTED = ("18.04", "22.04", "26.04")

# Debian architecture names used by apt repos and release tarballs.
_DEB_ARCH = {
    "x86_64": "amd64",
    "aarch64": "arm64",
    "armv7l": "armhf",
    "armv8l": "arm64",
}


def _os_release(path="/etc/os-release"):
    data = {}
    try:
        with open(path) as handle:
            for line in handle:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, value = line.split("=", 1)
                data[key.strip()] = value.strip().strip('"').strip("'")
    except (IOError, OSError):
        pass
    return data


class System:
    def __init__(self, user=None, home=None):
        release = _os_release()
        self.id = release.get("ID", "")
        self.version = release.get("VERSION_ID", "")
        self.codename = (
            release.get("VERSION_CODENAME")
            or release.get("UBUNTU_CODENAME")
            or ""
        )
        self.pretty = release.get("PRETTY_NAME", "unknown")
        self.arch = platform.machine()
        self.deb_arch = _DEB_ARCH.get(self.arch, self.arch)

        self.user = user or os.environ.get("SUDO_USER") or self._current_user()
        self.home = home or self._home_for(self.user)

    # -- identity ------------------------------------------------------
    @staticmethod
    def _current_user():
        try:
            return pwd.getpwuid(os.getuid()).pw_name
        except KeyError:
            return os.environ.get("USER", "root")

    @staticmethod
    def _home_for(user):
        try:
            return pwd.getpwnam(user).pw_dir
        except KeyError:
            return os.path.expanduser("~")

    # -- release helpers ----------------------------------------------
    @property
    def version_tuple(self):
        parts = []
        for chunk in self.version.split("."):
            if chunk.isdigit():
                parts.append(int(chunk))
        return tuple(parts)

    def at_least(self, major, minor=0):
        return self.version_tuple >= (major, minor)

    @property
    def is_deb822(self):
        """Ubuntu >= 24.04 uses the deb822 sources format."""
        return self.at_least(24, 4)

    @property
    def supported(self):
        return self.version in SUPPORTED

    def describe(self):
        return "%s (%s, %s)" % (self.pretty, self.arch, self.user)
