#!/bin/bash
cd ~/releases/ota

# Pull in the devices to transfer.
source ~/.WundermentOS/devices.sh

# Pull in the user/pass and host name to use for the transfer.
source ~/.WundermentOS/deploy-info.sh

# Use today's date for the filename.
TODAY=$(date +"%Y%m%d")

# Overide the current date if there is exactly one command line parameter.
if [ $# -eq 1 ]; then
	TODAY=$1
fi

for DEVICE in $WOS_DEVICES; do
	# Find out which version of LinageOS we're going to build for this device.
	WOS_BUILD_VAR=WOS_BUILD_VER_${DEVICE^^}
	LOS_BUILD_VERSION=${!WOS_BUILD_VAR}

	# Build the packagename, but leave out the extension as we're moving multiple files.
	PKGNAME=WundermentOS-$LOS_BUILD_VERSION-$TODAY-release-$DEVICE-signed

	# Make sure we have a package to deploy.
	if [ -f $PKGNAME.zip ]; then
		# Use lftp to do the transfer, note we'll transfer the file up to the sever with a "piz" extension
		# so taht the OTA updater doesn't pick it up and let users download it while it's uploading.
		# We'll rename it at the very end of the process to "zip" so the OTA will find it only after completely
		# all the transfers.
		lftp sftp://$WOS_USER:$WOS_PASS@$WOS_HOST -e "set sftp:auto-confirm yes; cd $WOS_DIR_FULL; put $PKGNAME.zip -o $PKGNAME.piz; put $PKGNAME.zip.md5sum; put $PKGNAME.zip.prop; mv $PKGNAME.piz $PKGNAME.zip; bye"

		# Save the date as the last release date for future use.
		echo $TODAY > ~/devices/$DEVICE/status/last.release.date.txt
	fi
done

# Flush the user/pass and host from the environment.
unset WOS_USER
unset WOS_PASS
unset WOS_HOST
unset WOS_DIR_FULL
