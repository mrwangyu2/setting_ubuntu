"""Install neovim, its config, vim-plug and the Python provider.

Neovim >= 0.9 is required by the config; when the distro package is older
(18.04/22.04) the neovim stable PPA is added. 26.04 ships 0.11+, so no PPA.
The deprecated ``LspInstall`` calls from the old scripts are gone: clangd
and ripgrep are installed as ordinary apt packages instead.
"""

import os
import re

from .. import apt, fileutil, log, pip

NAME = "nvim"
DESC = "Install neovim, config, vim-plug and Python provider"

PPA = "ppa:neovim-ppa/stable"
PLUG_URL = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"


def _needs_ppa(sh):
    version = sh.capture(["nvim", "--version"])
    if not version:
        return True
    match = re.match(r"NVIM v(\d+)\.(\d+)", version)
    if not match:
        return False
    return (int(match.group(1)), int(match.group(2))) < (0, 9)


def run(ctx):
    sh = ctx.sh
    home = ctx.system.home

    apt.ensure_installed(sh, ["software-properties-common", "curl"])
    apt.ensure_installed(sh, fileutil.read_list(ctx.resource("lists/nvim-apt.txt")))

    if _needs_ppa(sh):
        log.info("neovim too old for this config; adding %s" % PPA)
        sh.run(["add-apt-repository", "-y", PPA], sudo=True)
        apt.update(sh, force=True)
        apt.ensure_installed(sh, ["neovim"])

    fileutil.sync_dir(sh, ctx.resource("nvim_script"), os.path.join(home, ".config/nvim"))

    plug = os.path.join(home, ".local/share/nvim/site/autoload/plug.vim")
    if os.path.exists(plug):
        log.ok("vim-plug already installed")
    else:
        sh.run(["curl", "-fLo", plug, "--create-dirs", PLUG_URL], retries=3)

    sh.run(["nvim", "--headless", "-c", "PlugInstall", "-c", "qall"], check=False)
    pip.install_user(sh, ctx.system, fileutil.read_list(ctx.resource("lists/nvim-pip.txt")))
