"""Command execution with a single place to decide sudo / dry-run / logging."""

import os
import subprocess
import sys
import time

from . import log


class CommandError(Exception):
    def __init__(self, cmd, rc):
        self.cmd = cmd
        self.rc = rc
        Exception.__init__(self, "command failed (rc=%s): %s" % (rc, cmd))


def _quote(token):
    if token == "" or any(c in token for c in " \t\"'$&|;<>()"):
        return "'" + token.replace("'", "'\\''") + "'"
    return token


def _render(argv):
    return " ".join(_quote(a) for a in argv)


class Runner:
    """Runs commands. The only object that knows about sudo, --dry-run and
    the outbound proxy."""

    def __init__(self, dry_run=False, assume_yes=False, verbose=False, proxy=None):
        self.dry_run = dry_run
        self.assume_yes = assume_yes
        self.verbose = verbose
        # Fall back to the environment so `export https_proxy=...` is enough.
        self.proxy = (
            proxy
            or os.environ.get("https_proxy")
            or os.environ.get("http_proxy")
            or os.environ.get("all_proxy")
        )
        # Set by apt.update(); cleared by apt.ensure_repo() and mark_apt_stale()
        # so a changed repository is picked up before the next install.
        self.apt_updated = False

    # -- proxy ---------------------------------------------------------
    def _env(self):
        """Environment for spawned processes (git/curl/pip/npm honour these)."""
        if not self.proxy:
            return None
        env = dict(os.environ)
        for key in (
            "http_proxy",
            "https_proxy",
            "all_proxy",
            "HTTP_PROXY",
            "HTTPS_PROXY",
            "ALL_PROXY",
        ):
            env[key] = self.proxy
        env.setdefault("no_proxy", "localhost,127.0.0.1,::1")
        env.setdefault("NO_PROXY", env["no_proxy"])
        return env

    def apt_proxy_args(self):
        """apt ignores the environment, so the proxy is passed as -o options.
        sudo also resets the environment, so this works where env would not."""
        if not self.proxy:
            return []
        url = self.proxy.rstrip("/")
        return [
            "-o",
            "Acquire::http::Proxy=%s" % url,
            "-o",
            "Acquire::https::Proxy=%s" % url,
        ]

    # -- apt cache -----------------------------------------------------
    def mark_apt_stale(self):
        self.apt_updated = False

    # -- construction --------------------------------------------------
    def argv(self, cmd, sudo=False):
        if isinstance(cmd, str):
            argv = ["bash", "-c", cmd]
        else:
            argv = [str(a) for a in cmd]
        if sudo and os.geteuid() != 0:
            argv = ["sudo"] + argv
        return argv

    # -- running -------------------------------------------------------
    def run(
        self,
        cmd,
        check=True,
        sudo=False,
        capture=False,
        quiet=False,
        cwd=None,
        env=None,
        retries=1,
        retry_delay=2,
    ):
        """Run cmd. Returns (returncode, output). Raises CommandError when
        check=True and the command fails.

        retries>1 retries transient failures (network flakiness) with a fixed
        delay; used for git/curl/pip calls."""
        argv = self.argv(cmd, sudo=sudo)
        rendered = _render(argv)
        if self.dry_run:
            if not quiet:
                log.do("(dry-run) %s" % rendered)
            return 0, ""
        if not quiet:
            log.do(rendered)
        kwargs = {}
        if capture:
            kwargs["stdout"] = subprocess.PIPE
            kwargs["stderr"] = subprocess.STDOUT
        child_env = self._env() if env is None else env
        proc = None
        for attempt in range(1, retries + 1):
            proc = subprocess.run(
                argv, cwd=cwd, universal_newlines=True, env=child_env, **kwargs
            )
            if proc.returncode == 0:
                break
            if attempt < retries:
                log.warn(
                    "attempt %d/%d failed (rc=%s), retrying in %ss"
                    % (attempt, retries, proc.returncode, retry_delay)
                )
                time.sleep(retry_delay)
        out = proc.stdout or ""
        if capture and self.verbose and out:
            sys.stdout.write(out)
        if proc.returncode != 0:
            if check:
                log.fail("command failed (rc=%s): %s" % (proc.returncode, rendered))
                raise CommandError(rendered, proc.returncode)
            log.warn("command failed (rc=%s): %s" % (proc.returncode, rendered))
        return proc.returncode, out

    def capture(self, cmd, sudo=False):
        """Run and return stripped stdout, or None on failure."""
        rc, out = self.run(cmd, capture=True, check=False, sudo=sudo, quiet=True)
        if rc != 0:
            return None
        return out.strip()

    def succeeds(self, cmd, sudo=False):
        """True if the command exits 0."""
        rc, _ = self.run(cmd, capture=True, check=False, sudo=sudo, quiet=True)
        return rc == 0

    # -- interaction ---------------------------------------------------
    def confirm(self, message):
        """Ask before a surprising overwrite. --yes answers for you; a
        non-interactive run (no tty) answers 'no' rather than hanging."""
        if self.assume_yes:
            log.info("assume-yes: %s" % message)
            return True
        if self.dry_run:
            return True
        if not sys.stdin.isatty():
            log.warn("non-interactive, keeping existing file (%s)" % message)
            return False
        sys.stdout.write("%s [y/N] " % message)
        sys.stdout.flush()
        try:
            answer = input().strip().lower()
        except EOFError:
            return False
        return answer in ("y", "yes")
