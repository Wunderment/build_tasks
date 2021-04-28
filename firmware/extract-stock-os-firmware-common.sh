#!/bin/bash

# Get the device list and build types.
source ~/.WundermentOS/devices.sh

# Check to see if the configuration variables are set.
if [ "$VENDOR" == "" ] || [ "$DELETE_IMAGES" == "" ] || [ "$PREBUILT_VENDOR" == "" ]; then
	echo "Configuration missing, aborting."

	exit
fi

# Get the device name from the parent directory of this script's real path.
DEVICE=$(basename $(dirname $(dirname $(realpath $0))))

# A device name may have a special case where we're building multiple versions, like for LOS 16
# and 17.  In these cases an extra modifier on the device name is added that starts with a '_'
# so for example dumpling_17 to indicate to build LOS 17 for dumpling.  In these cases we need
# to leave the modifier on $DEVICE so logs and other commands are executed in the right directory
# but for the actual LOS build, we need to strip it off.  So do so now.
LOS_DEVICE=`echo $DEVICE | sed 's/_.*//'`

# Find out which version of LinageOS we're going to build for this device.
WOS_BUILD_VAR=WOS_BUILD_VER_${DEVICE^^}
LOS_BUILD_VERSION=${!WOS_BUILD_VAR}

# Check to see if we have the stock os file, if not throw an error.
if [ ! -f ~/devices/$DEVICE/stock_os/current-stock-os.zip ]; then
    echo "Stock OS not found for $DEVICE!"
	echo ""
	echo "Run \"../stock_os/get-stock-os.sh\" to retrieve it."
else
	cd ~/devices/$DEVICE/firmware

	# Create the image folder in the device tree if required.  Stores the final img files to be added to the OTA.
	if [ ! -d "~/android/lineage-$LOS_BUILD_VERSION/device/$VENDOR/$LOS_DEVICE/images" ]; then
		mkdir ~/android/lineage-$LOS_BUILD_VERSION/device/$VENDOR/$LOS_DEVICE/images
	fi

	# Create the image_raw folder if required.  Stores the raw img files extracted from OOS.
	if [ ! -d "images_raw" ]; then
		mkdir images_raw
	fi

	# Delete any previous extraction files.
	rm -rf ~/android/lineage-$LOS_BUILD_VERSION/device/$VENDOR/$LOS_DEVICE/images/*
	rm -rf ~/devices/$DEVICE/firmware/images_raw/*
	rm -f ~/devices/$DEVICE/firmware/vendor.img

	# Make sure we're in the firmware directory to start.
	cd ~/devices/$DEVICE/firmware/

	# Extract the payload.bin file from stock.
	unzip -o ~/devices/$DEVICE/stock_os/current-stock-os.zip payload.bin

	# Extract img files.
	python ~/android/lineage-$LOS_BUILD_VERSION/lineage/scripts/update-payload-extractor/extract.py --output_dir ./images_raw payload.bin

	# Change in to the output directory.
	cd images_raw

	# Get rid of the images we don't need.
	for IMAGE in $DELETE_IMAGES; do
		rm $IMAGE
	done

	# Change to the images directory.
	cd ~/android/lineage-$LOS_BUILD_VERSION/device/$VENDOR/$LOS_DEVICE/images

	# Copy over the raw images from OOS.
	cp ~/devices/$DEVICE/firmware/images_raw/*.img .

	# Remove vendor.img as we'll pull a version with the proper hashtree after the build is run.
	if [ "$PREBUILT_VENDOR" == "true" ]; then
		rm vendor.img
	fi

	# Return to the firmware directory.
	cd ~/devices/$DEVICE/firmware/

	# If we're keeping the vendor IMG, move it to it's home now.
	if [ "$PREBUILT_VENDOR" == "true" ]; then
		mv images_raw/vendor.img .
	fi

	# Cleanup time!
	rm payload.bin
	rm -rf images_raw
fi

