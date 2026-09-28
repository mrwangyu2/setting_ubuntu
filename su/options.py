"""The task-facing options, kept as a small typed object.

Tasks should not reach into a raw argparse Namespace: this gathers the few
values they actually need in one place, so the task surface is explicit.
"""


class Options:
    def __init__(self, mirror, pypi_mirror, timezone, upgrade, hosts_entries):
        self.mirror = mirror
        self.pypi_mirror = pypi_mirror
        self.timezone = timezone
        self.upgrade = upgrade
        self.hosts_entries = hosts_entries
