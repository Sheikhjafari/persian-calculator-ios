#!/usr/bin/env python3
"""Smoke-test startup in an available iPhone simulator and save a screenshot."""
import json
from pathlib import Path
import subprocess
import time

native = Path(__file__).resolve().parents[1]
def run(*args):
    return subprocess.check_output(['xcrun', 'simctl', *args], text=True, timeout=360).strip()
devices = json.loads(run('list', 'devices', 'available', '--json'))['devices']
candidates = [(runtime, device) for runtime, group in devices.items()
              if 'iOS' in runtime for device in group
              if device.get('isAvailable') and device['name'].startswith('iPhone')]
assert candidates, 'No available iPhone simulator runtime'
candidates.sort(key=lambda pair: ('iOS-26-2' in pair[0], pair[1]['name'] == 'iPhone 16'), reverse=True)
runtime, device = candidates[0]
udid = device['udid']
print('Simulator:', runtime, device['name'], flush=True)
try:
    if device['state'] != 'Booted':
        run('boot', udid)
    run('bootstatus', udid, '-b')
    run('status_bar', udid, 'override', '--time', '9:41', '--batteryState', 'charged', '--batteryLevel', '100')
    run('install', udid, str(native / 'DerivedDataSimulator/Build/Products/Debug-iphonesimulator/Calculator.app'))
    print(run('launch', udid, 'com.ali.personalcalculator'), flush=True)
    time.sleep(4)
    run('io', udid, 'screenshot', str(native / 'output/simulator.png'))
finally:
    subprocess.run(['xcrun', 'simctl', 'shutdown', udid], check=False)
