#!/bin/bash

# Import the device build details.
source ~/.WundermentOS/devices.sh

# Get the device name from the parent directory of this script's real path.
DEVICE=$(basename $(dirname $(dirname $(realpath $0))))

# A device name may have a special case where we're building multiple versions, like for LOS 16
# and 17.  In these cases an extra modifier on the device name is added that starts with a '_'
# so for example dumpling_17 to indicate to build LOS 17 for dumpling.  In these cases we need
# to leave the modifier on $DEVICE so logs and other commands are executed in the right directory
# but for the acutal LOS build, we need to strip it off.  So do so now.
LOS_DEVICE=`echo $DEVICE | sed 's/_.*//'`

# Find out which version of LinageOS we're going to build for this device.
WOS_BUILD_VAR=WOS_BUILD_VER_${DEVICE^^}
LOS_BUILD_VERSION=${!WOS_BUILD_VAR}

if [ "$LOS_BUILD_VERSION" == "" ]; then
	echo "ERROR: No LinageOS build version found, are you in a device directory?"
	exit
fi

# Make sure we're in the device's directory.
cd ~/devices/$DEVICE/stock_os

# Let's see what vendor patch level we should be using.
VENDOR_STRING="VENDOR_SECURITY_PATCH = "
grep "$VENDOR_STRING" ~/android/lineage-$LOS_BUILD_VERSION/device/google/$SECURITY_PATCH_FILE > vendor_string.txt

# Assign the result to a variable so we can check the result.
VENDOR_SECURITY_PATCH=`cat vendor_string.txt`

# Check to see if the vendor security patch level is set to the platform level, if so, go get the default value for it.
if [ "$VENDOR_SECURITY_PATCH" == "VENDOR_SECURITY_PATCH = \$(PLATFORM_SECURITY_PATCH)" ]; then
	echo "No vendor security string found, using platform default instead..."
	PLATFORM_STRING="PLATFORM_SECURITY_PATCH := "
	grep "$PLATFORM_STRING" ~/android/lineage-$LOS_BUILD_VERSION/build/make/core/version_defaults.mk > vendor_string.txt

	# Use the new platform string as the vendor string for cleanups.
	VENDOR_STRING=$PLATFORM_STRING
fi

# Cleanup the output so we just have the date.
sed -i "s/.*$VENDOR_STRING//" vendor_string.txt

# Save the more friendly formatting for later.
PRETTY_VENDOR_SECURITY_PATCH=`cat vendor_string.txt`

# Cleanup the output so we don't have any dashes.
sed -i "s/-//g" vendor_string.txt

# Assign the result to a variable and then remove the temporary file.
VENDOR_SECURITY_PATCH=`cat vendor_string.txt`
rm vendor_string.txt

# Trim off the first two characters of the year.
VENDOR_SECURITY_PATCH="${VENDOR_SECURITY_PATCH:2}"

if [ "$VENDOR_SECURITY_PATCH" == "" ]; then
	echo "ERROR: No vendor security patch level found in $SECURITY_PATCH_FILE!"
	exit;
fi

# Since we only want to update to a new stock os when LineageOS does, we can check the vendor patch date against the current
# stock os file url.  If the date isn't found in the current file url, we need to go get a new one, otherwise we can skip
# the rest.
if ! grep "$VENDOR_SECURITY_PATCH" last.stock.os.release.txt > /dev/null; then
	# Use curl to download the current info from Google for all Pixel devices.
	curl https://developers.google.com/android/ota -b "devsite_wall_acks=nexus-ota-tos,nexus-image-tos" > images.html  2> /dev/null

	# Split the page based on the current device name version.
	csplit images.html "/id=\"$LOS_DEVICE\"/" > /dev/null

	# Cleanup the images.html file as we're done with it.
	rm images.html

	# Split the page on the table layouts.
	csplit xx01 '/<\/table>/' > /dev/null

	# Cleanup and rename the part we want.
	mv xx00 table.txt
	rm xx*

	# Split the table on rows.
	csplit table.txt '/\<tr/' {*} > /dev/null

	# We no longer need the full table.
	rm table.txt

	# Grab the last download file that matches the date... this should be the file we're looking for but there
	# could be a conflict if two or more files match the date for some reason.
	grep -h "<a href=\"https://dl.google.com/dl/android/aosp.*$VENDOR_SECURITY_PATCH.*.zip\"" xx* | tail -1 > new.stock.os.release.txt

	# Cleanup the split parts from before.
	rm xx*

	# Time to cleanup the new url file and get ride of stuff we don't need.
	sed -i 's/\s*//' new.stock.os.release.txt
	sed -i 's/<td><a href="//' new.stock.os.release.txt
	sed -i 's/".*//' new.stock.os.release.txt

	# We need to download a stock os, so import the url we retrieved earlier in to a variable.
	STOCKURL=$(<new.stock.os.release.txt)

	echo "Updating stock OS OTA with: $STOCKURL..."

	# Remove the old stock os file.
	rm current-stock-os.zip

	# Download the new os file.
	wget -q -O current-stock-os.zip $STOCKURL

	# Replace the old url file with the new url file.
	rm last.stock.os.release.txt
	mv new.stock.os.release.txt last.stock.os.release.txt

	# Pixels have both a factory image and an OTA, so grab the factory image now.

	# Use curl to download the current info from Google for all Pixel devices.
	curl https://developers.google.com/android/images -b "devsite_wall_acks=nexus-image-tos,nexus-ota-tos" > images.html  2> /dev/null

	# Split the page based on the current device name version.
	csplit images.html "/id=\"$LOS_DEVICE\"/" > /dev/null

	# Cleanup the images.html file as we're done with it.
	rm images.html

	# Split the page on the table layouts.
	csplit xx01 '/<\/table>/' > /dev/null

	# Cleanup and rename the part we want.
	mv xx00 table.txt
	rm xx*

	# Split the table on rows.
	csplit table.txt '/\<tr/' {*} > /dev/null

	# We no longer need the full table.
	rm table.txt

	# Grab the last download file that matches the date... this should be the file we're looking for but there
	# could be a conflict if two or more files match the date for some reason.
	grep -h "<a href=\"https://dl.google.com/dl/android/aosp.*$VENDOR_SECURITY_PATCH.*.zip\"" xx* | tail -1 > new.stock.os.release.txt

	# Cleanup the split parts from before.
	rm xx*

	# Time to cleanup the new url file and get ride of stuff we don't need.
	sed -i 's/\s*//' new.stock.os.release.txt
	sed -i 's/<td><a href="//' new.stock.os.release.txt
	sed -i 's/".*//' new.stock.os.release.txt

	# We need to download a stock os, so import the url we retrieved earlier in to a variable.
	STOCKURL=$(<new.stock.os.release.txt)

	echo "Updating stock OS Factory Image with: $STOCKURL..."

	# Remove the old stock os file.
	rm current-stock-os-factory.zip

	# Download the new os file.
	wget -q -O current-stock-os-factory.zip $STOCKURL

	echo "Update complete."
else
	echo "No update needed, current stock os and vendor patch level are the same ($PRETTY_VENDOR_SECURITY_PATCH)."
fi

