"""The bundle passed to every task: which machine, how to run things, the
options they may consult, and where the resource files live."""

import os


class Context:
    def __init__(self, system, sh, options):
        self.system = system
        self.sh = sh
        self.options = options
        # su/context.py -> su -> repo root
        self.root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    def resource(self, *parts):
        return os.path.join(self.root, "resources", *parts)
