#!/bin/bash
cd ~/releases/ota

# Pull in the devices to transfer.
source ~/.WundermentOS/devices.sh

# Pull in the user/pass and host name to use for the transfer.
source ~/.WundermentOS/deploy-info.sh

# Use today's date for the filename.
TODAY=$(date +"%Y%m%d")

# Process the command line parameters if there are any.
if [ $# -gt 0 ]; then
	# Parameter 1 is always the date to deploy.
	TODAY=$1

	# Loop through the entire parameter list now looking for devices to deploy.
	for var in "$@"
	do
		# Computer the LOS build version for the parameter.
		WOS_BUILD_VAR=WOS_BUILD_VER_${var^^}
		LOS_BUILD_VERSION=${!WOS_BUILD_VAR}

		# Check to see if we have a valid build version for the passed in device.
		if [ "$LOS_BUILD_VERSION" != "" ]; then
			PROCESS_DEVICES="$PROCESS_DEVICES $var"
		fi
	done
fi

# Check to see if we have any devices to deploy, if not, fall back to the default list.
if [ "$PROCESS_DEVICES" == "" ]; then
	PROCESS_DEVICES="$WOS_DEVICES"
fi

for DEVICE in $PROCESS_DEVICES; do
	# Find out which version of LineageOS we're going to build for this device.
	WOS_BUILD_VAR=WOS_BUILD_VER_${DEVICE^^}
	LOS_BUILD_VERSION=${!WOS_BUILD_VAR}

	# A device name may have a special case where we're building multiple versios, like for LOS 16
	# and 17.  In these cases an extra modifier on the device name is added that starts with a '_'
	# so for example dumpling_17 to indicate to build LOS 17 for dumpling.  In these cases we need
	# to leave the modifier on $DEVICE so logs and other commands are executed in the right directory
	# but for the acutal LOS build, we need to strip it off.  So do so now.
	LOS_DEVICE=`echo $DEVICE | sed 's/_.*//'`

	# Change in to the device release directory.
	cd ~/releases/ota/$LOS_DEVICE

	# Build the packagename, but leave out the extension as we're moving multiple files.
	PKGNAME=WundermentOS-$LOS_BUILD_VERSION-$TODAY-release-$LOS_DEVICE-signed

	# Make sure we have a package to deploy.
	if [ -f $PKGNAME.zip ]; then
		echo "Deploying $PKGNAME..."
		# Use lftp to do the transfer, note we'll transfer the file up to the sever with a "piz" extension
		# so taht the OTA updater doesn't pick it up and let users download it while it's uploading.
		# We'll rename it at the very end of the process to "zip" so the OTA will find it only after completely
		# all the transfers.
		lftp sftp://$WOS_USER:$WOS_PASS@$WOS_HOST -e "set sftp:auto-confirm yes; cd $WOS_DIR_FULL; put $PKGNAME.zip -o $PKGNAME.piz; put $PKGNAME.zip.md5sum; put $PKGNAME.zip.prop; mv $PKGNAME.piz $PKGNAME.zip; bye"

		# Save the date as the last release date for future use.
		echo $TODAY > ~/devices/$LOS_DEVICE/status/last.release.date.txt
	fi
done

# Flush the user/pass and host from the environment.
unset WOS_USER
unset WOS_PASS
unset WOS_HOST
unset WOS_DIR_FULL
