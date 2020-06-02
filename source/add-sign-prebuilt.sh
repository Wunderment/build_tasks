#!/bin/bash

cp ~/tasks/source/sign_target_files_apks_vendor_prebuilt.py ~/android/lineage-17.1/build/tools/releasetools
cd ~/android/lineage-17.1/build/tools/releasetools
ln -s sign_target_files_apks_vendor_prebuilt.py sign_target_files_apks_vendor_prebuilt
