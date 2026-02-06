#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)
	LOSVERSION=$(echo $LOSDIRNAME | sed 's|.*-||')
	LOSMAJOR=$(echo $LOSVERSION | sed 's|\..*||')

	# Update the building process for pre-built images other than vendor, only supported on LOS 17+.
	if (( $LOSMAJOR >= 17 )); then
		echo "Patching Makefile for $LOSDIRNAME... "
		cd $LOSPATHNAME/build/make/core

		# Check to see if we need to patch the script before doing so.
		if ! grep "BOARD_PREBUILT_IMAGES_PATH" Makefile > /dev/null; then
			patch Makefile ~/tasks/source/core_Makefile-$LOSVERSION.patch
		fi

		cd ~/android/lineage-$LOSVERSION/build/tools/releasetools

		# Check to see if we need to patch the script before doing so.
		if ! grep "updating avb hash for prebuilt vendor.img..." add_img_to_target_files.py > /dev/null; then
			patch add_img_to_target_files.py ~/tasks/source/add_img_to_target_files.py-$LOSVERSION.patch
		fi

		# Check to see if we need to patch the script before doing so.
		if ! grep "prebuilts_path <path to prebuild image files>" sign_target_files_apks.py > /dev/null; then
			patch sign_target_files_apks.py ~/tasks/source/sign_target_files_apks.py-$LOSVERSION.patch
		fi
	fi
done