"""Install zsh, oh-my-zsh, its plugins, fzf and the managed .zshrc."""

import os

from .. import apt, fileutil, log

NAME = "zsh"
DESC = "Install zsh + oh-my-zsh plugins and the managed .zshrc"

OMZ_INSTALLER = (
    "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
)
PLUGINS = [
    ("zsh-autosuggestions", "https://github.com/zsh-users/zsh-autosuggestions"),
    ("zsh-syntax-highlighting", "https://github.com/zsh-users/zsh-syntax-highlighting"),
    (
        "zsh-history-substring-search",
        "https://github.com/zsh-users/zsh-history-substring-search",
    ),
    ("fzf-tab", "https://github.com/Aloxaf/fzf-tab"),
]


def run(ctx):
    sh = ctx.sh
    home = ctx.system.home
    apt.ensure_installed(sh, fileutil.read_list(ctx.resource("lists/zsh.txt")))

    omz = os.path.join(home, ".oh-my-zsh")
    if os.path.isdir(omz):
        log.ok("oh-my-zsh already installed")
    else:
        sh.run(
            'RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL %s)"' % OMZ_INSTALLER,
            retries=3,
        )

    for name, url in PLUGINS:
        fileutil.ensure_git(sh, url, os.path.join(omz, "custom/plugins", name))

    fzf = os.path.join(home, ".fzf")
    fileutil.ensure_git(sh, "https://github.com/junegunn/fzf", fzf)
    if os.path.exists(os.path.join(fzf, "bin", "fzf")):
        log.ok("fzf already built")
    else:
        sh.run([os.path.join(fzf, "install"), "--all", "--no-update-rc"], retries=2)

    fileutil.ensure_copy(
        sh, ctx.resource("zshrc.zsh-template"), os.path.join(home, ".zshrc"), protect=True
    )
