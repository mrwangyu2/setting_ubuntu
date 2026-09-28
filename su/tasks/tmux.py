"""Install tmux, tpm and the tmux plugins declared in tmux.conf."""

import os

from .. import apt, fileutil, log

NAME = "tmux"
DESC = "Install tmux + tpm plugins and the managed tmux.conf"


def run(ctx):
    sh = ctx.sh
    home = ctx.system.home
    apt.ensure_installed(sh, fileutil.read_list(ctx.resource("lists/tmux.txt")))

    plugins_dir = os.path.join(home, ".tmux/plugins")
    tpm = os.path.join(plugins_dir, "tpm")
    fileutil.ensure_git(sh, "https://github.com/tmux-plugins/tpm", tpm)
    fileutil.ensure_copy(
        sh, ctx.resource("tmux_script/tmux.conf"), os.path.join(home, ".tmux.conf"), protect=True
    )

    if os.path.isdir(os.path.join(plugins_dir, "tmux-resurrect")):
        log.ok("tmux plugins already installed")
    elif sh.dry_run:
        log.do("(dry-run) install tmux plugins via tpm")
    else:
        sh.run([os.path.join(tpm, "bin", "install_plugins")], check=False)

    theme_dir = os.path.join(plugins_dir, "tmux-powerline/themes")
    if os.path.isdir(theme_dir):
        fileutil.ensure_copy(
            sh, ctx.resource("tmux_script/default.sh"), os.path.join(theme_dir, "default.sh")
        )
    else:
        log.skip("tmux-powerline not installed (plugin is disabled in tmux.conf)")
