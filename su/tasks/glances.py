"""Install Glances (server + gotty web terminal).

Glances lives in a dedicated venv at /opt/glances so it never fights the
distro Python or PEP 668. Two systemd units are installed with paths filled
in for this machine, replacing the old ones that hardcoded /home/frank and
python3.10:

  glances.service          XML-RPC server,              port 61209
  glances_browser.service  gotty terminal running the
                           Glances client in browser,   port 8960
"""

import os

from .. import apt, fileutil, log, systemd

NAME = "glances"
DESC = "Install Glances server + gotty web terminal as systemd services"

VENV = "/opt/glances"
GOTTY = "/usr/local/bin/gotty"
CONF = "/etc/glances/glances.conf"

SERVER_UNIT = """[Unit]
Description=Glances server
Documentation=https://nicolargo.github.io/glances/
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=%(venv)s/bin/glances --server --config %(conf)s
Restart=on-failure
Nice=10

[Install]
WantedBy=multi-user.target
"""

BROWSER_UNIT = """[Unit]
Description=Glances web terminal (gotty)
After=network-online.target glances.service
Wants=network-online.target

[Service]
Environment=TERM=linux
Environment=TERMINFO=/etc/terminfo
ExecStart=%(gotty)s -p 8960 -w %(venv)s/bin/glances --browser --config %(conf)s
Restart=on-failure
Nice=10

[Install]
WantedBy=multi-user.target
"""


def _pip(sh, *args):
    """pip inside the venv; --proxy covers sudo resetting the environment."""
    cmd = [VENV + "/bin/pip"] + list(args)
    if sh.proxy:
        cmd += ["--proxy", sh.proxy]
    return cmd


def run(ctx):
    sh = ctx.sh
    apt.ensure_installed(sh, ["python3-venv"])

    if os.path.exists(os.path.join(VENV, "bin", "glances")):
        log.ok("glances venv already present")
    else:
        sh.run(["python3", "-m", "venv", VENV], sudo=True)
        sh.run(_pip(sh, "install", "--upgrade", "pip"), sudo=True, check=False, retries=2)
        sh.run(
            _pip(sh, "install", "glances", "fastapi", "uvicorn"),
            sudo=True,
            retries=3,
        )

    fileutil.ensure_binary(sh, ctx.resource("glances_script", "gotty"), GOTTY)
    fileutil.ensure_copy(
        sh, ctx.resource("glances_script", "glances.conf"), CONF, sudo=True
    )

    values = {"venv": VENV, "gotty": GOTTY, "conf": CONF}
    systemd.ensure_unit(sh, "glances.service", SERVER_UNIT % values)
    systemd.ensure_unit(sh, "glances_browser.service", BROWSER_UNIT % values)
