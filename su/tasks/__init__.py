"""The ordered task registry. Order matters: apt sources first, then the
packages and services that depend on them."""

from collections import namedtuple

Task = namedtuple("Task", "name desc func")


def all_tasks():
    from . import (
        apt_sources,
        pip_sources,
        hosts,
        timezone,
        base_packages,
        nodejs,
        docker,
        syncthing,
        glances,
        gdu,
        zsh,
        tmux,
        nvim,
    )

    modules = [
        apt_sources,
        pip_sources,
        hosts,
        timezone,
        base_packages,
        nodejs,
        docker,
        syncthing,
        glances,
        gdu,
        zsh,
        tmux,
        nvim,
    ]
    return [Task(m.NAME, m.DESC, m.run) for m in modules]
