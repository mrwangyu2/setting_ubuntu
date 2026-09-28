"""apt helpers built on dpkg/apt-get, all idempotent."""

import os
import tempfile

from . import fileutil, log


def installed(sh, package):
    status = sh.capture(["dpkg-query", "-W", "-f=${Status}", package])
    return bool(status) and "install ok installed" in status


def missing(sh, packages):
    return [p for p in packages if not installed(sh, p)]


def update(sh, force=False):
    """Run apt-get update at most once per invocation unless forced."""
    if sh.apt_updated and not force:
        log.skip("apt metadata already refreshed")
        return
    sh.run(["apt-get", "update"], sudo=True)
    sh.apt_updated = True


def ensure_installed(sh, packages):
    packages = [p for p in packages if p]
    if not packages:
        return
    todo = missing(sh, packages)
    if not todo:
        log.ok("already installed: %s" % ", ".join(packages))
        return
    log.info("installing: %s" % ", ".join(todo))
    sh.run(["apt-get", "install", "-y"] + todo, sudo=True)


def _same_file(a, b):
    try:
        with open(a, "rb") as fa, open(b, "rb") as fb:
            return fa.read() == fb.read()
    except (IOError, OSError):
        return False


def add_key(sh, url, keyring):
    """Install an (armoured) signing key as a keyring file, without apt-key.

    The key is re-fetched and compared on every run so a rotated upstream key
    is picked up. If the fetch fails but a keyring already exists, it is kept
    rather than failing the task.
    """
    if sh.dry_run:
        log.do("(dry-run) refresh apt key: %s -> %s" % (url, keyring))
        return
    handle, downloaded = tempfile.mkstemp()
    os.close(handle)
    handle, dearmoured = tempfile.mkstemp()
    os.close(handle)
    try:
        rc, _ = sh.run(["curl", "-fsSL", url, "-o", downloaded], check=False, quiet=True)
        if rc != 0:
            if os.path.exists(keyring):
                log.warn("could not refresh %s; keeping existing keyring" % keyring)
                return
            raise IOError("could not download apt key: %s" % url)
        sh.run(["gpg", "--dearmor", "--yes", "-o", dearmoured, downloaded], quiet=True)
        if _same_file(keyring, dearmoured):
            log.skip("keyring up to date: %s" % keyring)
            return
        log.do("install apt key: %s" % keyring)
        sh.run(["install", "-D", "-m", "0644", dearmoured, keyring], sudo=True, quiet=True)
    finally:
        for path in (downloaded, dearmoured):
            try:
                os.unlink(path)
            except OSError:
                pass


def ensure_repo(sh, filename, content):
    """Write /etc/apt/sources.list.d/<filename>, returning True if changed."""
    path = os.path.join("/etc/apt/sources.list.d", filename)
    changed = fileutil.write(sh, path, content, sudo=True, backup=False)
    if changed:
        sh.mark_apt_stale()
    return changed


def ensure_signed_repo(sh, filename, key_url, keyring, repo_line):
    """Add a signing key and its repository in one step."""
    add_key(sh, key_url, keyring)
    return ensure_repo(sh, filename, repo_line)
