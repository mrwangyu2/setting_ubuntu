"""Command line entry point.

    setup.py list                 show tasks
    setup.py plan [tasks...]      show what a run would change (dry-run)
    setup.py run  [tasks...]      apply tasks (default: all, in order)
"""

import argparse
import os
import traceback

from . import log
from .context import Context
from .mirrors import APT_MIRRORS, PYPI_MIRRORS
from .options import Options
from .runner import Runner
from .system import System
from .tasks import all_tasks

COMMANDS = ("list", "plan", "run")


def build_parser():
    parser = argparse.ArgumentParser(
        prog="setup.py",
        description="Idempotent Ubuntu bootstrap for 18.04 / 22.04 / 26.04",
        epilog="Re-running any task is safe: it only applies what is missing.",
    )
    parser.add_argument("--dry-run", action="store_true", help="show changes, change nothing")
    parser.add_argument("--yes", action="store_true", help="answer yes to overwrite prompts")
    parser.add_argument("--no-color", action="store_true", help="disable ANSI colours")
    parser.add_argument("--verbose", action="store_true", help="print tracebacks on failure")
    parser.add_argument(
        "--force", action="store_true", help="proceed on an unsupported Ubuntu release"
    )
    parser.add_argument(
        "--mirror", default="aliyun", choices=sorted(APT_MIRRORS), help="apt mirror"
    )
    parser.add_argument(
        "--pypi-mirror",
        default=None,
        choices=sorted(PYPI_MIRRORS),
        help="pip mirror (default: same as --mirror)",
    )
    parser.add_argument("--timezone", default="Asia/Shanghai", help="system timezone")
    parser.add_argument(
        "--proxy",
        default=None,
        metavar="URL",
        help="HTTP(S) proxy for git/curl/pip/apt, e.g. http://192.168.3.10:7897 "
        "(default: $https_proxy / $http_proxy)",
    )
    parser.add_argument("--user", default=None, help="target user (default: invoking user)")
    parser.add_argument("--home", default=None, help="target home (default: from the user)")
    parser.add_argument(
        "--upgrade", action="store_true", help="refresh standalone binaries such as gdu"
    )
    parser.add_argument(
        "--hosts-entry",
        action="append",
        default=[],
        metavar="IP HOST",
        help="static /etc/hosts entry, repeatable (used by the hosts task)",
    )
    parser.add_argument("command", nargs="?", default="run", choices=COMMANDS)
    parser.add_argument("tasks", nargs="*", help="task names (default: all, in order)")
    return parser


def _select_tasks(requested):
    tasks = all_tasks()
    if not requested:
        return tasks, None
    names = []
    for token in requested:
        names.extend(name for name in token.split(",") if name)
    index = dict((task.name, task) for task in tasks)
    unknown = [name for name in names if name not in index]
    if unknown:
        return None, unknown
    return [index[name] for name in names], None


def _cmd_list():
    log.header("Available tasks")
    for task in all_tasks():
        print("  %-14s %s" % (task.name, task.desc))
    return 0


def _warn_if_root(args):
    if os.geteuid() == 0 and not os.environ.get("SUDO_USER") and not args.user:
        log.warn(
            "running as root with no --user: user-scoped tasks will target /root. "
            "Run as a normal user, or pass --user."
        )


def main(argv):
    args = build_parser().parse_args(argv)
    log.configure(color=(False if args.no_color else None))

    if args.command == "list":
        return _cmd_list()

    if args.command == "plan":
        args.dry_run = True

    selected, unknown = _select_tasks(args.tasks)
    if unknown:
        log.fail("unknown task(s): %s" % ", ".join(unknown))
        log.info("known tasks: %s" % ", ".join(t.name for t in all_tasks()))
        return 2

    system = System(user=args.user, home=args.home)
    log.header("setting_ubuntu on %s" % system.describe())
    if not system.supported and not args.force:
        log.fail(
            "Ubuntu %s is not a supported target (%s). Use --force to try anyway."
            % (system.version or "?", ", ".join(("18.04", "22.04", "26.04")))
        )
        return 2
    if not system.supported:
        log.warn("unsupported Ubuntu %s; continuing because --force was given" % system.version)

    _warn_if_root(args)

    if args.dry_run:
        log.info("dry-run: no changes will be made")

    runner = Runner(
        dry_run=args.dry_run,
        assume_yes=args.yes,
        verbose=args.verbose,
        proxy=args.proxy,
    )
    options = Options(
        mirror=args.mirror,
        pypi_mirror=args.pypi_mirror,
        timezone=args.timezone,
        upgrade=args.upgrade,
        hosts_entries=args.hosts_entry,
    )
    ctx = Context(system, runner, options)

    results = []
    for task in selected:
        log.header("%s — %s" % (task.name, task.desc))
        try:
            task.func(ctx)
            results.append((task.name, True))
        except Exception as exc:  # noqa: BLE001 - report and continue
            results.append((task.name, False))
            log.fail("%s: %s" % (task.name, exc))
            if args.verbose:
                traceback.print_exc()

    log.header("Summary")
    failed = 0
    for name, ok in results:
        if ok:
            log.ok(name)
        else:
            failed += 1
            log.fail(name)
    if failed:
        log.warn("%d of %d task(s) failed" % (failed, len(results)))
        return 1
    log.ok("all %d task(s) completed" % len(results))
    return 0
