#!/bin/bash

# Get the device list.
source ~/.WundermentOS/devices.sh

# Import the destination e-mail address to send logs to.
source ~/.WundermentOS/log-email-address.sh

# Update all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	# Change in to the lineage build directory.
	cd ~/android/$LOSDIRNAME

	# Update the source code from GitHub.
	echo "Executing repo sync for $LOSDIRNAME..."
	~/bin/repo sync --force-sync > ~/tasks/cron/logs/$LOSDIRNAME-repo-sync.log 2>&1

	# Check to see if repo sync failed for some reason.
	# Note: grep returns 0 when it matches some lines and 1 when it doesn't.
	grep "error" ~/tasks/cron/logs/$LOSDIRNAME-repo-sync.log >/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		# Send the log via e-mail
		cat ~/tasks/cron/logs/$LOSDIRNAME-repo-sync.log | mail -s "WundermentOS $LOSDIRNAME Repo Sync Error" $WOS_LOGDEST

		# Exit the current loop and proceed to the next.
		continue	
	fi

	# Find out how long ago the F-Droid apk was downloaded (in seconds).
	LASTFD=$(expr `date +%s` - `stat -c %Z ~/android/$LOSDIRNAME/packages/apps/F-Droid/F-Droid.apk`)
done

# Loop through our devices to be built.
for DEVICE in $WOS_DEVICES; do
	echo "Checking secruity patch level for $DEVICE..."

	# Find out which version of LineageOS we're going to build for this device.
	WOS_BUILD_VAR=WOS_BUILD_VER_${DEVICE^^}
	LOS_BUILD_VERSION=${!WOS_BUILD_VAR}

	# Let's see if we've had a security patch update since yesterday.
	grep "PLATFORM_SECURITY_PATCH :=" ~/android/lineage-$LOS_BUILD_VERSION/build/core/version_defaults.mk > ~/devices/$DEVICE/status/current.security.patch.txt
	diff ~/devices/$DEVICE/status/last.security.patch.txt ~/devices/$DEVICE/status/current.security.patch.txt > /dev/null 2>&1
	if [ $? -eq 1 ]
	then
		echo "New security update for $DEVICE!"
   		cp ~/devices/$DEVICE/status/current.security.patch.txt ~/devices/$DEVICE/status/last.security.patch.txt

		# check to see if we should re-download F-Droid.apk before running the build.
		if [ $LASTFD -gt 86400 ]; then
			echo "Downloading F-Droid..."

			cd ~/tasks/source
			./update-f-droid-apk.sh

			# Reset the LASTFD variable so we don't download FDroid.apk for each device we're building for.
			LASTFD=0
		fi

		# Update blobs and firmware.
		echo "Updating $DEVICE stock os..."
		cd ~/devices/$DEVICE/stock_os
   		./get-stock-os.sh

  		# Start the build/sign process.
		echo "Building $DEVICE..."
		cd ~/devices/$DEVICE/build
   		./build.sh clean_build_sign

		cd ~/tasks/cron
	else
		echo "No security update for $DEVICE."
	fi
done
