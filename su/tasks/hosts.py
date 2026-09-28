"""Pin static host entries in /etc/hosts, opt-in.

The old script appended a hardcoded, long-dead IP on every run. This uses a
managed block instead, so re-running replaces the block rather than
duplicating it. Nothing is written unless --hosts-entry is given, e.g.

    ./setup.py run hosts --hosts-entry "203.0.113.10 raw.githubusercontent.com"
"""

from .. import fileutil, log

NAME = "hosts"
DESC = "Pin static IPs in /etc/hosts via --hosts-entry (opt-in)"

BLOCK_ID = "static-hosts"


def run(ctx):
    entries = [e.strip() for e in ctx.options.hosts_entries if e.strip()]
    if not entries:
        log.skip("no --hosts-entry given; /etc/hosts left alone")
        return
    fileutil.ensure_block(ctx.sh, "/etc/hosts", BLOCK_ID, entries, sudo=True)
