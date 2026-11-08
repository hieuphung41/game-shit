"""Unit tests for APK verification output parsing, with no Android SDK required."""
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


REPO = Path(__file__).resolve().parents[2]
VERIFY = REPO / "tools" / "ci" / "verify_apk.sh"


class VerifyApkTest(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        self.bin = self.tmp / "bin"
        self.bin.mkdir()
        self.apk = self.tmp / "staging.apk"
        self.apk.write_bytes(b"not a real apk; mocked tools inspect it")
        self.build_info = self.tmp / "build_info.cfg"
        self.build_info.write_text('[build]\nchannel="staging"\nversion="0.1.0-staging+abc1234"\n')

    def tearDown(self):
        shutil.rmtree(self.tmp)

    def verify(self, cert, badging, signer_status=0, aapt_status=0):
        env = os.environ.copy()
        env["PATH"] = f"{self.bin}:{env['PATH']}"
        env["BUILD_INFO"] = str(self.build_info)
        env["apksigner_OUTPUT"] = cert
        env["apksigner_STATUS"] = str(signer_status)
        env["aapt_OUTPUT"] = badging
        env["aapt_STATUS"] = str(aapt_status)
        (self.bin / "apksigner").write_text(
            "#!/usr/bin/env bash\nprintf '%s\\n' \"$apksigner_OUTPUT\"\nexit \"$apksigner_STATUS\"\n"
        )
        (self.bin / "aapt").write_text(
            "#!/usr/bin/env bash\nprintf '%s\\n' \"$aapt_OUTPUT\"\nexit \"$aapt_STATUS\"\n"
        )
        (self.bin / "apksigner").chmod(0o755)
        (self.bin / "aapt").chmod(0o755)
        return subprocess.run([str(VERIFY), str(self.apk)], text=True, capture_output=True, env=env)

    @staticmethod
    def badging(package="vn.hieuphung.kheuoctanvuong.staging", version="0.1.0-staging+abc1234"):
        return f"package: name='{package}' versionCode='1' versionName='{version}' platformBuildVersionName=''"

    def test_accepts_debug_certificate_package_and_staging_version(self):
        result = self.verify("Signer #1 certificate DN: CN=Android Debug, O=Android, C=US", self.badging())
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_rejects_non_debug_certificate(self):
        result = self.verify("Signer #1 certificate DN: CN=Release Signing, O=Studio", self.badging())
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("not Android Debug", result.stderr)

    def test_rejects_wrong_package(self):
        result = self.verify("Signer #1 certificate DN: CN=Android Debug", self.badging(package="example.other"))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("package is", result.stderr)

    def test_rejects_version_name_missing_build_version(self):
        result = self.verify("Signer #1 certificate DN: CN=Android Debug", self.badging(version="0.1.0"))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("versionName", result.stderr)

    def test_rejects_unverifiable_signature(self):
        result = self.verify("", self.badging(), signer_status=1)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("could not verify", result.stderr)


if __name__ == "__main__":
    unittest.main()
