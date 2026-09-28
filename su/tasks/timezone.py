"""Set the system timezone, skipping the call when it already matches."""

from .. import log

NAME = "timezone"
DESC = "Set the system timezone"


def run(ctx):
    target = ctx.options.timezone
    current = ctx.sh.capture(["timedatectl", "show", "-p", "Timezone", "--value"])
    if current == target:
        log.ok("timezone already %s" % target)
        return
    log.info("setting timezone -> %s" % target)
    ctx.sh.run(["timedatectl", "set-timezone", target], sudo=True)
