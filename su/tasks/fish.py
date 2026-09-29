"""Install fish shell, Fisher package manager, fish-ai and base configuration."""

import os

from .. import apt, fileutil, log

NAME = "fish"
DESC = "Install fish shell, Fisher, fish-ai and base configuration"

FISHER_INSTALLER = "https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish"


def run(ctx):
    sh = ctx.sh
    home = ctx.system.home

    # 1. Ensure fish and required build/git dependencies are installed via apt
    apt.ensure_installed(sh, fileutil.read_list(ctx.resource("lists/fish.txt")))

    # 2. Deploy ~/.config/fish/config.fish
    fish_config_dir = os.path.join(home, ".config/fish")
    fileutil.ensure_copy(
        sh,
        ctx.resource("fish_script/config.fish"),
        os.path.join(fish_config_dir, "config.fish"),
        protect=True,
    )

    # 3. Deploy ~/.config/fish-ai.ini
    fileutil.ensure_copy(
        sh,
        ctx.resource("fish_script/fish-ai.ini"),
        os.path.join(home, ".config/fish-ai.ini"),
        protect=True,
    )

    # 4. Install Fisher plugin manager idempotently
    fisher_path = os.path.join(fish_config_dir, "functions/fisher.fish")
    if os.path.exists(fisher_path):
        log.ok("fisher already installed")
    else:
        log.info("installing fisher")
        sh.run(
            [
                "fish",
                "-c",
                "curl -sL %s | source && fisher install jorgebucaran/fisher"
                % FISHER_INSTALLER,
            ],
            retries=3,
            check=False,
        )

    # 5. Install fish-ai plugin idempotently
    fish_ai_installed = os.path.exists(
        os.path.join(home, ".local/share/fish-ai/bin/lookup_setting")
    )
    if fish_ai_installed:
        log.ok("fish-ai already installed")
    else:
        log.info("installing fish-ai via fisher")
        src_dir = os.path.join(home, ".local/src/fish-ai")
        fileutil.ensure_git(sh, "https://github.com/realiserad/fish-ai", src_dir)
        sh.run(["fish", "-c", "fisher install %s" % src_dir], retries=2, check=False)

