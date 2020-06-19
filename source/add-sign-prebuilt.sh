#!/bin/bash

# Note: Update the building process for prebuilt images other than vendor, only supported on LOS 17.1.

cd ~/android/lineage-17.1/build/make/core

# Check to see if we need to patch the script before doing so.
if ! grep "BOARD_PREBUILT_IMAGES_PATH" Makefile > /dev/null; then
        patch Makefile ~/tasks/source/core_Makefile.patch
fi

# Note: Update the signing process for prebuilt vendor and other images, only supported on LOS 17.1.

cd ~/android/lineage-17.1/build/tools/releasetools

# Check to see if we need to patch the script before doing so.
if ! grep "updating avb hash for prebuilt vendor.img..." add_image_to_target_files.py > /dev/null; then
        patch add_image_to_target_files.py ~/tasks/source/add_image_to_target_files.py.patch
fi

# Check to see if we need to patch the script before doing so.
if ! grep "--prebuilts_path <path to prebuild image files>" sign_target_files_apks.py > /dev/null; then
        patch sign_target_files_apks.py ~/tasks/source/sign_target_files_apks.py.patch
fi

