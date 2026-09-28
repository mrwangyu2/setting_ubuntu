"""pip helper.

Ubuntu >= 24.04 marks the Python environment externally managed (PEP 668),
so --user installs need --break-system-packages there. Older releases do
not understand that flag, which is why it is added conditionally.

When a proxy is configured it is passed as --proxy rather than relying on
the environment, because sudo resets the environment for root installs.
"""


def install_user(sh, system, packages):
    packages = [p for p in packages if p]
    if not packages:
        return
    cmd = ["python3", "-m", "pip", "install", "--user"]
    if system.at_least(24, 4):
        cmd.append("--break-system-packages")
    if sh.proxy:
        cmd += ["--proxy", sh.proxy]
    sh.run(cmd + packages, retries=3)
