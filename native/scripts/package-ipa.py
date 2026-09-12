#!/usr/bin/env python3
"""Package a device build for local re-signing; no Apple credentials needed."""
import hashlib
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import tempfile
import zipfile

native = Path(__file__).resolve().parents[1]
app = native / 'DerivedData/Build/Products/Release-iphoneos/Calculator.app'
out = native / 'output'
out.mkdir(exist_ok=True)
with (app / 'Info.plist').open('rb') as f:
    info = plistlib.load(f)
assert info['CFBundleSupportedPlatforms'] == ['iPhoneOS'], 'Not a device build'
assert info['CFBundlePackageType'] == 'APPL'
binary = app / info['CFBundleExecutable']
architectures = subprocess.check_output(['xcrun', 'lipo', '-archs', str(binary)], text=True).strip()
assert 'arm64' in architectures.split(), architectures
ipa = out / 'Calculator-unsigned.ipa'
with tempfile.TemporaryDirectory(prefix='calculator-ipa-') as folder:
    payload = Path(folder) / 'Payload'
    payload.mkdir()
    shutil.copytree(app, payload / app.name)
    subprocess.run(['ditto', '-c', '-k', '--keepParent', str(payload), str(ipa)], check=True)
with zipfile.ZipFile(ipa) as archive:
    assert archive.testzip() is None
    assert 'Payload/Calculator.app/Info.plist' in archive.namelist()
    assert 'Payload/Calculator.app/' + info['CFBundleExecutable'] in archive.namelist()
digest = hashlib.sha256(ipa.read_bytes()).hexdigest()
(out / 'SHA256SUMS').write_text(digest + '  ' + ipa.name + '\n')
metadata = {
    'bundle_identifier': info['CFBundleIdentifier'],
    'version': info['CFBundleShortVersionString'],
    'minimum_ios': info['MinimumOSVersion'],
    'architectures': architectures,
    'signed': False,
    'commit': os.environ.get('GITHUB_SHA', ''),
    'run_id': os.environ.get('GITHUB_RUN_ID', ''),
    'xcode': subprocess.check_output(['xcodebuild', '-version'], text=True).strip(),
    'sha256': digest,
    'installation': 'Re-sign with your Apple account in iloader or SideStore before installing.'
}
(out / 'build-info.json').write_text(json.dumps(metadata, indent=2) + '\n')
print(json.dumps(metadata, indent=2))
