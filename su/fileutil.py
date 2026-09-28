"""Idempotent filesystem operations.

The whole point: every one of these functions is safe to call again. They
either report [SKIP]/[ OK ] when the desired state already holds, or apply
exactly the delta. Nothing appends blindly.
"""

import os
import shutil
import tempfile

from . import log

_BLOCK_BEGIN = "# >>> setting_ubuntu:%s >>>"
_BLOCK_END = "# <<< setting_ubuntu:%s <<<"
_BACKUP_SUFFIX = ".setting_ubuntu.bak"


def read(path):
    try:
        with open(path, "r") as handle:
            return handle.read()
    except (IOError, OSError):
        return None


def read_bytes(path):
    try:
        with open(path, "rb") as handle:
            return handle.read()
    except (IOError, OSError):
        return None


def read_list(path):
    """Read a resource list: one item per line, '#' comments and blanks kept out."""
    content = read(path)
    if content is None:
        raise IOError("resource list not found: %s" % path)
    items = []
    for line in content.splitlines():
        line = line.split("#", 1)[0].strip()
        if line:
            items.append(line)
    return items


def _backup(path):
    dest = path + _BACKUP_SUFFIX
    if os.path.exists(path) and not os.path.exists(dest):
        shutil.copy2(path, dest)


def _sudo_write(sh, path, content, mode, backup):
    handle, tmp = tempfile.mkstemp()
    try:
        with os.fdopen(handle, "w") as out:
            out.write(content)
        if backup and os.path.exists(path):
            sh.run(["cp", "-a", path, path + _BACKUP_SUFFIX], sudo=True, check=False, quiet=True)
        sh.run(["install", "-D", "-m", mode, tmp, path], sudo=True, quiet=True)
    finally:
        try:
            os.unlink(tmp)
        except OSError:
            pass


def write(sh, path, content, sudo=False, mode="0644", backup=True, protect=False):
    """Write content only when it differs. Returns True when a change was made.

    protect=True asks for confirmation before clobbering a pre-existing,
    user-owned file (skipped automatically in a non-interactive run)."""
    if read(path) == content:
        log.skip("unchanged: %s" % path)
        return False
    if protect and os.path.exists(path) and not sh.confirm("Overwrite %s?" % path):
        log.warn("kept existing: %s" % path)
        return False
    log.do("write %s" % path)
    if sh.dry_run:
        return True
    if sudo:
        _sudo_write(sh, path, content, mode, backup)
    else:
        parent = os.path.dirname(path)
        if parent and not os.path.isdir(parent):
            os.makedirs(parent)
        if backup:
            _backup(path)
        with open(path, "w") as handle:
            handle.write(content)
    return True


def ensure_block(sh, path, block_id, lines, sudo=False):
    """Maintain a marked block inside a file, replacing it on every run so
    re-running never duplicates lines."""
    begin = _BLOCK_BEGIN % block_id
    end = _BLOCK_END % block_id
    block = "%s\n%s\n%s\n" % (begin, "\n".join(lines), end)
    content = read(path) or ""
    if begin in content and end in content:
        start = content.index(begin)
        stop = content.index(end) + len(end) + 1
        new_content = content[:start] + block + content[stop:]
    else:
        new_content = content
        if new_content and not new_content.endswith("\n"):
            new_content += "\n"
        new_content += block
    return write(sh, path, new_content, sudo=sudo, backup=False)


def ensure_copy(sh, src, dest, sudo=False, protect=False):
    """Copy src to dest only when the contents differ."""
    content = read(src)
    if content is None:
        raise IOError("resource not found: %s" % src)
    return write(sh, dest, content, sudo=sudo, backup=True, protect=protect)


def sync_dir(sh, src, dest, sudo=False):
    """Recursively mirror a resource directory, touching only changed files."""
    changed = 0
    for root, _dirs, files in os.walk(src):
        rel = os.path.relpath(root, src)
        target_dir = dest if rel == "." else os.path.join(dest, rel)
        for name in files:
            source = os.path.join(root, name)
            target = os.path.join(target_dir, name)
            if ensure_copy(sh, source, target, sudo=sudo):
                changed += 1
    return changed


def ensure_git(sh, url, dest, update=False):
    """Clone a repo if absent; optionally fast-forward an existing clone."""
    if os.path.isdir(os.path.join(dest, ".git")):
        if update:
            sh.run(["git", "-C", dest, "pull", "--ff-only"], check=False)
        else:
            log.skip("already cloned: %s" % dest)
        return False
    sh.run(["git", "clone", "--depth", "1", url, dest])
    return True


def ensure_binary(sh, src, dest, mode="0755", sudo=True):
    """Install a binary resource only when its bytes differ (text mode would
    choke on executables such as gotty)."""
    source = read_bytes(src)
    if source is None:
        raise IOError("resource not found: %s" % src)
    if source == read_bytes(dest):
        log.skip("unchanged: %s" % dest)
        return False
    log.do("install %s" % dest)
    if sh.dry_run:
        return True
    sh.run(["install", "-D", "-m", mode, src, dest], sudo=sudo, quiet=True)
    return True
