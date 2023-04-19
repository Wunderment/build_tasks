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
	echo -n "Executing repo sync for $LOSDIRNAME... "
	~/bin/repo sync --force-sync > ~/tasks/cron/logs/$LOSDIRNAME-repo-sync.log 2>&1

	echo "done."

	# Update the git lfs objects.
	echo -n "Executing git lfs pull for $LOSDIRNAME... "
	grep -l 'merge=lfs' $( find . -name .gitattributes ) /dev/null | while IFS= read -r line; do
		dir=$(dirname $line)
		echo $dir > ~/tasks/cron/logs/$LOSDIRNAME-repo-sync.log 2>&1
		( cd $dir ; git lfs pull > ~/tasks/cron/logs/$LOSDIRNAME-repo-sync.log 2>&1 )
	done

	echo "done."

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
done

# Update the f-droid apk if required.
cd ~/tasks/source
./update-f-droid-apk.sh

# Update the NetworkLocation apk if required.
cd ~/tasks/source
./update-networklocation-apk.sh

# Loop through our devices to be built.
for DEVICE in $WOS_DEVICES; do
	echo -n "Checking secruity patch level for $DEVICE... "

	# Find out which version of LineageOS we're going to build for this device.
	WOS_BUILD_VAR=WOS_BUILD_VER_${DEVICE^^}
	LOS_BUILD_VERSION=${!WOS_BUILD_VAR}

	# Let's see if we've had a security patch update since yesterday.
	grep "PLATFORM_SECURITY_PATCH :=" ~/android/lineage-$LOS_BUILD_VERSION/build/core/version_defaults.mk > ~/devices/$DEVICE/status/current.security.patch.txt
	diff ~/devices/$DEVICE/status/last.security.patch.txt ~/devices/$DEVICE/status/current.security.patch.txt > /dev/null 2>&1
	if [ $? -eq 1 ]
	then
		echo "new security update for $DEVICE!"
   		cp ~/devices/$DEVICE/status/current.security.patch.txt ~/devices/$DEVICE/status/last.security.patch.txt

		# Update blobs and firmware.
		echo "Updating $DEVICE stock os..."
		cd ~/devices/$DEVICE/stock_os
   		./get-stock-os.sh

  		# Start the build/sign process.
		echo "Building $DEVICE..."
		cd ~/devices/$DEVICE/build
   		./build.sh clean build sign log

		cd ~/tasks/cron
	else
		echo "no security update for $DEVICE."
	fi

	rm ~/devices/$DEVICE/status/current.security.patch.txt
done
