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

function sign_wos_target_apks_vendor_prebuilt {
	echo "Sign target APK's with prebuilt vendor..."
	./build/tools/releasetools/sign_target_files_apks_vendor_prebuilt -o -d ~/.android-certs --vendor_prebuilt ~/devices/$DEVICE/blobls/vendor.img $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip signed-target_files.zip
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

function send_build_sign_log {
	WOS_LOG_TEMP=$(mktemp)
	WOS_LOG_FILE=~/devices/$DEVICE/logs/build-sign-wundermentos.log
	WOS_LOG_ZIP=~/devices/$DEVICE/logs/build-sign-wundermentos.log.zip 

	head $WOS_LOG_FILE > $WOS_LOG_TEMP
	echo " " >> $WOS_LOG_TEMP
	echo "." >> $WOS_LOG_TEMP
	echo "." >> $WOS_LOG_TEMP
	echo "." >> $WOS_LOG_TEMP
	echo " " >> $WOS_LOG_TEMP
	tail $WOS_LOG_FILE >> $WOS_LOG_TEMP

	# Zip the log file because it can be very large, but junk the path.
	zip -j $WOS_LOG_ZIP $WOS_LOG_FILE > /dev/null 2>&1

	cat $WOS_LOG_TEMP | mutt -s "WundermentOS Build Log for $DEVICE" $WOS_LOGDEST -a $WOS_LOG_ZIP

	rm $WOS_LOG_TEMP
	rm $WOS_LOG_ZIP
}
