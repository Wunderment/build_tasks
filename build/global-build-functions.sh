#!/bin/bash

# Print the help screen.
function help_screen {
        echo ""
        if [ -z ${SCRIPT_TITLE+x} ]; then
                echo "Usage: ./build.sh <action> ... <action> <target>"
        else
                echo $SCRIPT_TITLE
        fi

	echo ""
	echo "Supported actions are:"
	echo "    build      - Run WundermentOS build"
	echo "    clean      - Run a make clean"
	echo "    foreground - Run commands in the foreground"
	echo "    log        - Log output"
	echo "    nohup      - Run commands in the background (forces log)"
	echo "    sign       - Run WundermentOS sign"
	echo ""
}

# Common build functions, should be used for virtually all devices.
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

	TARGET_PRODUCT=lineage_$LOS_DEVICE
	export TARGET_PRODUCT

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

# Clean the out directory and other files, minty fresh when done.
function clean_wos {
	echo "Cleaning the build system..."

	# Move in to the build directory
	cd ~/android/lineage-$LOS_BUILD_VERSION

	# Setup the build environment
	source build/envsetup.sh
	croot

	make clean
}

# Common signing functions, should be used for none A/B devices.
function sign_wos_target_apks {
	echo "Sign target APK's..."
	./build/tools/releasetools/sign_target_files_apks -o -d ~/.android-certs $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip signed-target_files.zip
}

# Common signing functions, should be used for A/B devices with a prebuilt vendor.img, which
# is the case for most LineageOS 17.1 devices.
function sign_wos_target_apks_vendor_prebuilt {
	echo "Sign target APK's with prebuilt vendor partitions..."

	# Make sure our vendor image directory exists.
	if [ ! -d ~/android/lineage-$LOS_BUILD_VERSION/device/$VENDOR/$LOS_DEVICE/images/vendor ]; then
		mkdir ~/android/lineage-$LOS_BUILD_VERSION/device/$VENDOR/$LOS_DEVICE/images/vendor
	fi

	# Get the signed vendor.img from the out directory.
	cp $OUT/obj/PACKAGING/target_files_intermediates/lineage_$LOS_DEVICE-target_files-eng.WundermentOS/IMAGES/vendor.img ~/android/lineage-$LOS_BUILD_VERSION/device/$VENDOR/$LOS_DEVICE/images/vendor

	# Sign the apks.
	./build/tools/releasetools/sign_target_files_apks -o -d ~/.android-certs --prebuilts_path ~/android/lineage-$LOS_BUILD_VERSION/device/$VENDOR/$LOS_DEVICE/images/vendor $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip signed-target_files.zip
}

# Common OTA generation functions, should be used for virtually all devices.
function sign_wos_target_files {
	# Create the release file
	echo "Create release file: $PKGNAME..."
	./build/tools/releasetools/ota_from_target_files -k ~/.android-certs/releasekey --block signed-target_files.zip ~/releases/ota/$LOS_DEVICE/$PKGNAME.zip
}

# Super function to sign and generate the OTA, should only be used for non-A/B devices.
function sign_wos_target_package {
	sign_wos_target_apks
	sign_wos_target_files
}

# Common checksum and buildprop generation function, basically the cleanup once everything else is done.
function checksum_buildprop_cleanup {
    # Create the md5 checksum file for the release
    echo "Create the md5 checksum..."
    md5sum ~/releases/ota/$LOS_DEVICE/$PKGNAME.zip > ~/releases/ota/$LOS_DEVICE/$PKGNAME.zip.md5sum

    # Grab a copy of the build.prop file
    echo "Extract the build.prop file..."
    unzip -j signed-target_files.zip SYSTEM/build.prop
    mv build.prop ~/releases/ota/$LOS_DEVICE/$PKGNAME.zip.prop
    touch -r ~/releases/ota/$LOS_DEVICE/$PKGNAME.zip.md5sum ~/releases/ota/$LOS_DEVICE/$PKGNAME.zip.prop

    # Cleanup
    echo "Store signed target files for future incremental updates..."
    mv signed-target_files.zip ~/releases/signed_files/$LOS_DEVICE/signed-target_files-$LOS_DEVICE-$TODAY.zip
}

# E-mail out the build/sign log.
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

# Validate the release file size.
function validate_release_size {
	echo -n "Validating release size... " >> $OUTDEV	# Get the file names for the last two releases.
	NEWFILE=$(ls -t ~/releases/ota/$LOS_DEVICE/WundermentOS-*-release-*-signed.zip | head -n 1)
	OLDFILE=$(ls -t ~/releases/ota/$LOS_DEVICE/WundermentOS-*-release-*-signed.zip | head -n 2 | tail -n 1)

	# Now get their file sizes.
	NEWSIZE=$(stat -c%s $NEWFILE)
	OLDSIZE=$(stat -c%s $OLDFILE)

	# Make it look pretty for display later.
	FNEWSIZE=$(printf "%'d" $NEWSIZE)
	FOLDSIZE=$(printf "%'d" $OLDSIZE)

	# If one of the filesize is 0, then we shouldn't bother checking as one of them doesn't exist.
	if [ $NEWSIZE -gt 0 ] && [ $OLDSIZE -gt 0 ]; then
		# Make sure we don't calculate a negative percentage.
		if [ $NEWSIZE -lt $OLDSIZE ]; then
			PERCENT=$(bc <<< "scale=0; ($OLDSIZE - $NEWSIZE)/$NEWSIZE")
		else
			PERCENT=$(bc <<< "scale=0; ($NEWSIZE - $OLDSIZE)/$OLDSIZE")
		fi

		# Now let's make sure we haven't varied from the last build by too much.
		if [ $PERCENT -gt 0 ]; then
			if [ $DOLOG == "true" ]; then
				echo $'New release size: '"$FNEWSIZE"$'\nOld release size: '"$FOLDSIZE"$'\nPercentage change: '"$PERCENT"$'%\nDevice: '"$DEVICE" | mail -s "WundermentOS release size change is too large for $DEVICE!" $WOS_LOGDEST
			fi

			echo $'[WARNING] Percentage change since last signing is too large!\nNew release size: '"$FNEWSIZE"$'\nOld release size: '"$FOLDSIZE"$'\nPercentage change: '"$PERCENT"$'%\nDevice: '"$DEVICE" >> $OUTDEV
		else
			echo " new file size is $FNEWSIZE bytes... done." >> $OUTDEV
		fi
	else
		echo "skipping, only one file to compare." >> $OUTDEV
	fi
}