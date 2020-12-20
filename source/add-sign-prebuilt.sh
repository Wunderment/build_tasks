#!/bin/bash

# Note: Update the building process for pre-built images other than vendor, only supported on LOS 17.1 +.
ANDROID_VERSIONS=( 17.1 18.0 18.1 )

for i in "${ANDROID_VERSIONS[@]}"; do
	echo "Patching Android $i..."
	cd ~/android/lineage-$i/build/make/core

	# Check to see if we need to patch the script before doing so.
	if ! grep "BOARD_PREBUILT_IMAGES_PATH" Makefile > /dev/null; then
		patch Makefile ~/tasks/source/core_Makefile-$i.patch
	fi

	cd ~/android/lineage-$i/build/tools/releasetools

	# Check to see if we need to patch the script before doing so.
	if ! grep "updating avb hash for prebuilt vendor.img..." add_img_to_target_files.py > /dev/null; then
		patch add_img_to_target_files.py ~/tasks/source/add_img_to_target_files.py-$i.patch
	fi

	# Check to see if we need to patch the script before doing so.
	if ! grep "prebuilts_path <path to prebuild image files>" sign_target_files_apks.py > /dev/null; then
		patch sign_target_files_apks.py ~/tasks/source/sign_target_files_apks.py.patch
	fi

done
