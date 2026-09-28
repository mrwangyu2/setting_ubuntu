#!/usr/bin/env python3
"""Standard-library tests for the pure / offline parts of setup.py.

Run with:  python3 -m unittest discover -s tests -v

These cover the logic that is easy to get wrong and hard to see on a single
machine: the sources.list rendering for each supported release, the
idempotency primitives, and the option/system parsing. Nothing here touches
the network or the system.
"""

import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from su import fileutil, mirrors  # noqa: E402
from su.options import Options  # noqa: E402
from su.runner import Runner  # noqa: E402
from su.system import System  # noqa: E402
from su.tasks import apt_sources, nodejs  # noqa: E402
import su.system as system_module  # noqa: E402


def fake_release(version, codename):
    original = system_module._os_release
    system_module._os_release = lambda path="/etc/os-release": {
        "ID": "ubuntu",
        "VERSION_ID": version,
        "VERSION_CODENAME": codename,
        "PRETTY_NAME": "Ubuntu %s" % version,
    }
    return original


class SystemTest(unittest.TestCase):
    def _system(self, version, codename):
        original = fake_release(version, codename)
        try:
            return System(user="tester", home="/home/tester")
        finally:
            system_module._os_release = original

    def test_supported_releases_use_the_expected_sources_format(self):
        cases = {
            ("18.04", "bionic"): False,
            ("22.04", "jammy"): False,
            ("26.04", "resolute"): True,
        }
        for (version, codename), deb822 in cases.items():
            system = self._system(version, codename)
            self.assertTrue(system.supported, version)
            self.assertEqual(system.is_deb822, deb822, version)
            self.assertEqual(system.codename, codename)

    def test_other_releases_are_unsupported(self):
        self.assertFalse(self._system("20.04", "focal").supported)
        self.assertFalse(self._system("24.04", "noble").supported)

    def test_version_tuple_ignores_non_digits(self):
        self.assertEqual(self._system("26.04", "resolute").version_tuple, (26, 4))


class SourcesRenderingTest(unittest.TestCase):
    def test_classic_format_lists_every_suite(self):
        text = apt_sources._classic("http://mirror/ubuntu/", "jammy")
        for suite in ("jammy", "jammy-updates", "jammy-backports", "jammy-security"):
            self.assertIn("deb http://mirror/ubuntu/ %s main restricted universe multiverse" % suite, text)
        self.assertNotIn("Types:", text)

    def test_deb822_format_has_two_stanzas_and_signed_by(self):
        text = apt_sources._deb822("http://mirror/ubuntu/", "resolute")
        self.assertEqual(text.count("Types: deb"), 2)
        self.assertIn("Suites: resolute resolute-updates resolute-backports", text)
        self.assertIn("Suites: resolute-security", text)
        self.assertIn("Signed-By: %s" % apt_sources.SIGNED_BY, text)


class NodeMajorTest(unittest.TestCase):
    def test_node_major_by_release(self):
        for version, codename, expected in (
            ("18.04", "bionic", "16"),
            ("22.04", "jammy", "22"),
            ("26.04", "resolute", "22"),
        ):
            original = fake_release(version, codename)
            try:
                system = System(user="tester", home="/home/tester")
            finally:
                system_module._os_release = original
            self.assertEqual(nodejs._major(system), expected, version)


class FileutilTest(unittest.TestCase):
    def setUp(self):
        self.sh = Runner()
        self.dir = tempfile.mkdtemp()

    def test_write_is_a_noop_when_content_is_equal(self):
        path = os.path.join(self.dir, "a.conf")
        self.assertTrue(fileutil.write(self.sh, path, "hello\n"))
        self.assertFalse(fileutil.write(self.sh, path, "hello\n"))

    def test_ensure_block_replaces_instead_of_appending(self):
        path = os.path.join(self.dir, "hosts")
        fileutil.ensure_block(self.sh, path, "demo", ["1.1.1.1 a"])
        fileutil.ensure_block(self.sh, path, "demo", ["2.2.2.2 b"])
        fileutil.ensure_block(self.sh, path, "demo", ["2.2.2.2 b"])
        content = fileutil.read(path)
        self.assertEqual(content.count(">>> setting_ubuntu:demo >>>"), 1)
        self.assertIn("2.2.2.2 b", content)
        self.assertNotIn("1.1.1.1 a", content)

    def test_read_list_skips_comments_and_blanks(self):
        path = os.path.join(self.dir, "list.txt")
        with open(path, "w") as handle:
            handle.write("# comment\n\nzsh\n  git  # trailing\n")
        self.assertEqual(fileutil.read_list(path), ["zsh", "git"])

    def test_ensure_binary_compares_bytes(self):
        src = os.path.join(self.dir, "src.bin")
        dest = os.path.join(self.dir, "dest.bin")
        with open(src, "wb") as handle:
            handle.write(b"\x00\x01\x02")
        self.assertTrue(fileutil.ensure_binary(self.sh, src, dest, sudo=False))
        self.assertFalse(fileutil.ensure_binary(self.sh, src, dest, sudo=False))


class RunnerTest(unittest.TestCase):
    def test_capture_and_succeeds(self):
        sh = Runner()
        self.assertEqual(sh.capture(["printf", "ok"]), "ok")
        self.assertTrue(sh.succeeds(["true"]))
        self.assertFalse(sh.succeeds(["false"]))
        self.assertIsNone(sh.capture(["false"]))

    def test_dry_run_runs_nothing(self):
        sh = Runner(dry_run=True)
        rc, out = sh.run(["false"])
        self.assertEqual(rc, 0)
        self.assertEqual(out, "")
        self.assertTrue(sh.confirm("overwrite?"))  # dry-run answers yes


class OptionsTest(unittest.TestCase):
    def test_carries_the_task_facing_values(self):
        options = Options(
            mirror="tuna",
            pypi_mirror=None,
            timezone="UTC",
            upgrade=True,
            hosts_entries=["1.2.3.4 example.com"],
        )
        self.assertEqual(options.mirror, "tuna")
        self.assertEqual(options.hosts_entries, ["1.2.3.4 example.com"])


class MirrorsTest(unittest.TestCase):
    def test_default_mirror_exists_in_both_tables(self):
        self.assertIn("aliyun", mirrors.APT_MIRRORS)
        self.assertIn("aliyun", mirrors.PYPI_MIRRORS)


if __name__ == "__main__":
    unittest.main()
