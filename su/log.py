"""Tiny colour-aware logger.

Every line is prefixed with a short tag so a run is easy to scan:

    [ OK ]  nothing to do, already in the desired state
    [DO  ]  action being performed
    [SKIP]  intentionally not touched
    [WARN]  non-fatal problem
    [FAIL]  fatal problem for the current task
"""

import os
import sys

_COLORS = {
    "OK": "32",
    "DO": "36",
    "SKIP": "90",
    "WARN": "33",
    "FAIL": "31",
    "INFO": "34",
    "----": "1;34",
}

_enabled = None


def configure(color=None):
    """Decide once whether ANSI colour should be used."""
    global _enabled
    if color is None:
        color = sys.stdout.isatty() and not os.environ.get("NO_COLOR")
    _enabled = bool(color)


def _emit(tag, msg):
    if _enabled is None:
        configure()
    prefix = "[%s]" % tag
    if _enabled:
        prefix = "\033[%sm%s\033[0m" % (_COLORS.get(tag, "0"), prefix)
    sys.stdout.write("%s %s\n" % (prefix, msg))
    sys.stdout.flush()


def info(msg):
    _emit("INFO", msg)


def ok(msg):
    _emit("OK", msg)


def do(msg):
    _emit("DO", msg)


def skip(msg):
    _emit("SKIP", msg)


def warn(msg):
    _emit("WARN", msg)


def fail(msg):
    _emit("FAIL", msg)


def header(msg):
    if _enabled is None:
        configure()
    if _enabled:
        sys.stdout.write("\n\033[1;34m== %s ==\033[0m\n" % msg)
    else:
        sys.stdout.write("\n== %s ==\n" % msg)
    sys.stdout.flush()
