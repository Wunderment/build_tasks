#!/bin/bash

# Note: SeedVault only supports Android 10.

cd ~/android/lineage-17.1/frameworks/base/packages/SettingsProvider/src/com/android/providers/settings

if ! grep "Version 184: Update default Backup app to Seedvault" SettingsProvider.java > /dev/null; then
	patch SettingsProvider.java ~/tasks/source/SettingsProvider.java.patch
fi
