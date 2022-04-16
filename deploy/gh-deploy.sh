#!/bin/bash

if ! command -v gh &> /dev/null
then
    echo "ERROR: Github CLI client not installed!"
    exit
fi

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
		# Compute the LOS build version for the parameter.
		WOS_BUILD_VAR=WOS_BUILD_VER_${var^^}
		LOS_BUILD_VERSION=${!WOS_BUILD_VAR}

		# Check to see if we have a valid build version for the passed in device.
		if [ "$LOS_BUILD_VERSION" != "" ]; then
			PROCESS_DEVICES="$PROCESS_DEVICES $var"
		fi
	done
fi

# Create a pretty date to use for later.
PRETTYTODAY=$(date -d $TODAY +"%B %d, %Y")

# Check to see if we have any devices to deploy, if not, fall back to the default list.
if [ "$PROCESS_DEVICES" == "" ]; then
	if [ $# -gt 1 ]; then
		echo "One or more devices were not found, aborting!"
		exit
	fi

	PROCESS_DEVICES="$WOS_DEVICES"
fi

echo "Processing device list: $PROCESS_DEVICES..."

DEPLOY_FILES=""
DEPLOY_DEVICES=""

for DEVICE in $PROCESS_DEVICES; do
	# Find out which version of LineageOS we're going to build for this device.
	WOS_BUILD_VAR=WOS_BUILD_VER_${DEVICE^^}
	LOS_BUILD_VERSION=${!WOS_BUILD_VAR}

	# A device name may have a special case where we're building multiple versions, like for LOS 16
	# and 17.  In these cases an extra modifier on the device name is added that starts with a '_'
	# so for example dumpling_17 to indicate to build LOS 17 for dumpling.  In these cases we need
	# to leave the modifier on $DEVICE so logs and other commands are executed in the right directory
	# but for the acutal LOS build, we need to strip it off.  So do so now.
	LOS_DEVICE=`echo $DEVICE | sed 's/_.*//'`

	# Change in to the device release directory.
	cd ~/releases/ota/$LOS_DEVICE

	# Build the packagename, but leave out the extension as we're moving multiple files.
	PKGNAME="WundermentOS-$LOS_BUILD_VERSION-$TODAY-release-$LOS_DEVICE-signed"

	# Make sure we have a package to deploy.
	if [ -f $PKGNAME.zip ]; then
		# Define the recovery image to add to the release.
		RECOVERYNAME="WundermentOS-$LOS_BUILD_VERSION-$TODAY-recovery-$LOS_DEVICE"

		echo "Found release for $LOS_DEVICE, deploying to Github..."
		DEPLOY_FILES="$HOME/releases/ota/$LOS_DEVICE/$PKGNAME.zip $HOME/releases/ota/$LOS_DEVICE/$RECOVERYNAME.zip $HOME/releases/ota/$LOS_DEVICE/$PKGNAME.zip.md5sum $HOME/releases/ota/$LOS_DEVICE/$PKGNAME.zip.prop"

		# We need to be in the repo directory for gh to work.
		cd ~/github/$WOS_GH_REPO

		# Create a tag for the release on Github using the current time.
		GHTAG=$(date +"$LOS_DEVICE-%Y-%m-%d-%k-%M-%S")

		# Use Github's command line too gh to do a release.
		# -d 	Draft
		# -t 	Release title
		# -n 	Release notes
		# GHTAG Github tag to create for the release
		# FILES Files to add to the release
		gh release create -d \
		                  -t "WundermentOS release on $PRETTYTODAY for $LOS_DEVICE" \
		                  -n "WundermentOS release with monthly security patches and fixes." \
		                  $GHTAG \
		                  $DEPLOY_FILES

		# We created the release as a draft so that it wasn't visible to the LineageOTA updater before all
		# the files were uploaded, so let's correct that now.
		gh release edit $GHTAG --draft=false

		# Make the output pretty with a blank line.
		echo ""

		# Save the date as the last release date for future use.
		echo $TODAY > ~/devices/$DEVICE/status/last.release.date.txt

		# Lets update the "latest" pointer on the OTA server.
		PKGHTMLNAME="WundermentOS-$LOS_DEVICE-latest.html"
		echo "<head>" > $PKGHTMLNAME
  		echo "  <meta http-equiv=\"refresh\" content=\"5; URL=https://github.com/Wunderment/releases/releases/download/$GHTAG/$PKGNAME.zip\" />" >> $PKGHTMLNAME
		echo "</head>" >> $PKGHTMLNAME
		echo "<body>" >> $PKGHTMLNAME
		echo "  <p>If you are not redirected to your file in five seconds <a href=\"https://github.com/Wunderment/releases/releases/download/$GHTAG/$PKGNAME.zip\">click here</a>.</p>" >> $PKGHTMLNAME
		echo "</body>" >> $PKGHTMLNAME

		RECOVERYHTMLNAME="WundermentOS-$LOS_DEVICE-recovery.html"
		echo "<head>" > $RECOVERYHTMLNAME
  		echo "  <meta http-equiv=\"refresh\" content=\"5; URL=https://github.com/Wunderment/releases/releases/download/$GHTAG/$PKGNAME.zip\" />" >> $RECOVERYHTMLNAME
		echo "</head>" >> $RECOVERYHTMLNAME
		echo "<body>" >> $RECOVERYHTMLNAME
		echo "  <p>If you are not redirected to your file in five seconds <a href=\"https://github.com/Wunderment/releases/releases/download/$GHTAG/$PKGNAME.zip\">click here</a>.</p>" >> $RECOVERYHTMLNAME
		echo "</body>" >> $RECOVERYHTMLNAME

		# Now transfer the redirect file to the webserver and replace the old one.
		lftp sftp://$WOS_USER:$WOS_PASS@$WOS_HOST -e "set sftp:auto-confirm yes; cd $WOS_DIR_FULL; cd ..; rm $PKGHTMLNAME; put $PKGHTMLNAME; rm $RECVOERYHTMLNAME; put $RECOVERYHTMLNAME; bye"

		# Cleanup time.
		rm $PKGHTMLNAME
		rm $RECOVERYHTMLNAME

		REALDEPLOY=true
	fi
done

# Check to see if we really deployed some files, if so do some cleanup.
if [ "$REALDEPLOY" == "true" ]; then
	# Go flush the Github cache file on the webserver.
	lftp sftp://$WOS_USER:$WOS_PASS@$WOS_HOST -e "set sftp:auto-confirm yes; cd $WOS_DIR_FULL; rm ../../github.cache.json; bye"
fi

# Flush the user/pass and host from the environment.
unset WOS_USER
unset WOS_PASS
unset WOS_HOST
unset WOS_DIR_FULL
unset WOS_GH_REPO
