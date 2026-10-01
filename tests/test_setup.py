"""Nix・Homebrew・実ホームを変更せず、操作の分離と停止条件を確認する。"""

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[1]


class SetupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-setup-test-")
        self.root = Path(self.temp.name).resolve()
        self.repo = self.root / "repo with spaces"
        self.repo.mkdir()
        shutil.copytree(REPO / "scripts", self.repo / "scripts")
        shutil.copy2(REPO / "Makefile", self.repo / "Makefile")
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.calls = self.root / "calls.jsonl"
        self.env = dict(os.environ, PATH=str(self.bin) + os.pathsep + os.environ["PATH"],
                        SETUP_TEST_CALLS=str(self.calls))
        self.tool("uname", "import sys\nprint('Darwin' if sys.argv[1] == '-s' else 'arm64')\n")
        self.tool("nix", '''import json, os, pathlib, sys
args = sys.argv[1:]
with open(os.environ['SETUP_TEST_CALLS'], 'a') as log:
    log.write(json.dumps(args) + '\\n')
args = args[2:]
if args[:2] == ['flake', 'lock']:
    pathlib.Path('flake.lock').write_text('{"test_fixture": true}\\n')
elif args[:2] == ['flake', 'update']:
    pathlib.Path('flake.lock').write_text('{"updated_test_fixture": true}\\n')
elif args[0] == 'eval':
    print('deliberately-not-the-current-account')
elif args[0] == 'build':
    if os.environ.get('SETUP_TEST_BUILD_FAIL'):
        sys.exit(7)
    print('/nix/store/test-only-no-real-activation-package')
''')
        self.tool("brew", '''import json, os, sys
with open(os.environ['SETUP_TEST_CALLS'], 'a') as log:
    log.write(json.dumps({'args': sys.argv[1:],
        'auto_update': os.environ.get('HOMEBREW_NO_AUTO_UPDATE'),
        'cleanup': os.environ.get('HOMEBREW_NO_INSTALL_CLEANUP')}) + '\\n')
''')

    def tearDown(self):
        self.temp.cleanup()

    def tool(self, name, source):
        path = self.bin / name
        path.write_text('#!' + sys.executable + '\n' + source)
        path.chmod(0o755)

    def run_script(self, script, *args):
        return subprocess.run(['/bin/bash', str(self.repo / 'scripts' / script), *args],
                              cwd=self.repo, env=self.env, text=True, capture_output=True, timeout=15)

    def recorded(self):
        return [json.loads(line) for line in self.calls.read_text().splitlines()] if self.calls.exists() else []

    def lock(self):
        (self.repo / 'flake.lock').write_text('{"test_fixture": true}\n')

    def test_default_and_legacy_make_targets_do_not_call_installers(self):
        for target in (None, 'all', 'bootstrap', 'install', 'deploy', 'clean'):
            result = subprocess.run(['/usr/bin/make'] + ([target] if target else []),
                                    cwd=self.repo, env=self.env, capture_output=True, timeout=15)
            self.assertEqual(result.returncode, 2 if target in ('install', 'deploy', 'clean') else 0)
        self.assertEqual(self.recorded(), [])

    def test_missing_lock_prevents_build_and_activation(self):
        for operation in ('check', 'build', 'apply', 'update'):
            result = self.run_script('home.sh', operation)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('flake.lock is missing', result.stderr)
        self.assertEqual(self.recorded(), [])

    def test_init_lock_is_explicit_and_does_not_overwrite(self):
        self.assertEqual(self.run_script('home.sh', 'init-lock').returncode, 0)
        original = (self.repo / 'flake.lock').read_bytes()
        self.assertNotEqual(self.run_script('home.sh', 'init-lock').returncode, 0)
        self.assertEqual((self.repo / 'flake.lock').read_bytes(), original)
        self.assertEqual(len(self.recorded()), 1)

    def test_build_and_check_do_not_update_lock_or_activate(self):
        self.lock()
        for operation in ('build', 'check'):
            self.assertEqual(self.run_script('home.sh', operation).returncode, 0)
        for args in self.recorded():
            self.assertIn('--no-update-lock-file', args)
            self.assertIn('--no-write-lock-file', args)
        self.assertEqual(json.loads((self.repo / 'flake.lock').read_text()), {'test_fixture': True})

    def test_failed_build_stops(self):
        self.lock()
        self.env['SETUP_TEST_BUILD_FAIL'] = '1'
        self.assertEqual(self.run_script('home.sh', 'build').returncode, 7)
        self.assertEqual(len(self.recorded()), 1)

    def test_update_checks_build_without_applying(self):
        self.lock()
        self.assertEqual(self.run_script('home.sh', 'update').returncode, 0)
        calls = self.recorded()
        self.assertEqual([args[2:4] for args in calls], [['flake', 'update'], ['flake', 'check']])

    def test_wrong_account_prevents_activation(self):
        self.lock()
        result = self.run_script('home.sh', 'apply')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Account does not match', result.stderr)
        self.assertTrue(all(args[2] == 'eval' for args in self.recorded()))

    def test_preflight_rejects_symlink_parents_and_overlapping_files(self):
        target = self.root / 'target home'
        target.mkdir()
        original = self.root / 'existing config'
        original.mkdir()
        sentinel = original / 'keep.txt'
        sentinel.write_text('keep\n')
        (target / '.config').symlink_to(original, target_is_directory=True)
        self.assertNotEqual(self.run_script('preflight-home.sh', str(target)).returncode, 0)
        self.assertEqual(sentinel.read_text(), 'keep\n')
        (target / '.config').unlink()
        (target / '.gitconfig').write_text('existing config\n')
        self.assertNotEqual(self.run_script('preflight-home.sh', str(target)).returncode, 0)
        self.assertEqual((target / '.gitconfig').read_text(), 'existing config\n')

    def test_preflight_can_repeat_without_creating_files(self):
        target = self.root / 'fresh home'
        target.mkdir()
        for _ in range(2):
            self.assertEqual(self.run_script('preflight-home.sh', str(target)).returncode, 0)
        self.assertEqual(list(target.iterdir()), [])

    def test_apps_uses_only_minimal_brewfile_and_disables_upgrades(self):
        self.assertEqual(self.run_script('apps.sh').returncode, 0)
        call, = self.recorded()
        self.assertEqual(call['args'], ['bundle', '--file=' + str(self.repo / 'Brewfile.macos'), '--no-upgrade'])
        self.assertEqual(call['auto_update'], '1')
        self.assertEqual(call['cleanup'], '1')


if __name__ == '__main__':
    unittest.main()
