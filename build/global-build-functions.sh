#!/bin/bash

# Print the help screen.
function help_screen {
        echo ""
        if [ -z ${SCRIPT_TITLE+x} ]; then
                echo "Usage: ./build.sh <action> <target>"
        else
                echo $SCRIPT_TITLE
        fi

	echo ""
	echo "Supported actions are:"
	echo "    build_only       - Run WAS build with logging"
	echo "    build_sign       - Run WOS build and sign with logging"
	echo "    build            - Run WOS build in foreground"
	echo "    nohup_build      - Run WOS build in the background with logging"
	echo "    nohup_build_sign - Run WOS build and sign in the background with logging"
	echo "    sign             - Run WAS sign in foreground"
	echo ""
}

function common_build_wos {
	echo "Start build process for $DEVICE..."

	# Move in to the build directory
	cd ~/android/lineage-$LOS_BUILD_VERSION

	# Setup the build environment
	source build/envsetup.sh
	croot

	# Setup our env variables
	RELEASE_TYPE=RELEASE
	export RELEASE_TYPE

	TARGET_BUILD_VARIANT=user
	export TARGET_BUILD_VARIANT

	# Clean the build environment.
	make installclean

	# Start the build
	echo "Running breakfast for $LOS_DEVICE..."
	breakfast $LOS_DEVICE user

	# Package the files
	echo "Making target packages for $DEVICE..."
	mka target-files-package otatools

	echo "Build process complete for $DEVICE!"
}

function sign_wos_target_apks {
	echo "Sign target APK's..."
	./build/tools/releasetools/sign_target_files_apks -o -d ~/.android-certs $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip signed-target_files.zip
}

function sign_wos_target_files {
	# Create the release file
	echo "Create release file: $PKGNAME..."
	./build/tools/releasetools/ota_from_target_files -k ~/.android-certs/releasekey --block signed-target_files.zip ~/releases/ota/$PKGNAME.zip
}


function sign_wos_target_package {
	sign_wos_target_apks
	sign_wos_target_files
}

