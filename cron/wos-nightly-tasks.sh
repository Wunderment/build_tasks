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

	# Flush the old log.
	echo "" > ~/tasks/cron/logs/$LOSDIRNAME-repo-sync.log

	# Update the git lfs objects.
	echo -n "Executing git lfs pull for $LOSDIRNAME... "
	grep -l 'merge=lfs' $( find . -name .gitattributes ) /dev/null | while IFS= read -r line; do
		dir=$(dirname $line)
		echo "Executing git lfs pull for $dir" >> ~/tasks/cron/logs/$LOSDIRNAME-repo-sync.log 2>&1
		( cd $dir ; git reset --hard ; ~/bin/repo sync . ; git lfs pull ) >> ~/tasks/cron/logs/$LOSDIRNAME-repo-sync.log 2>&1
	done

	echo "done."

	# Update the source code from GitHub.
	echo -n "Executing repo sync for $LOSDIRNAME... "
	~/bin/repo sync --force-sync >> ~/tasks/cron/logs/$LOSDIRNAME-repo-sync.log 2>&1

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

	# Cleanup the values folder for stray .orig files
	cd lineage-sdk/lineage/res/res
	find . -name *.orig -exec rm {} \;
done

# Update the f-droid apk if required.
cd ~/tasks/source
./update-f-droid-apk.sh

# Update the NetworkLocation apk if required.
# UnfiedNLP is no longer supported past Android 11.
# cd ~/tasks/source
# ./update-networklocation-apk.sh

# Loop through our devices to be built.
for DEVICE in $WOS_DEVICES; do
	echo -n "Checking security patch level for $DEVICE... "

	# Find out which version of LineageOS we're going to build for this device.
	WOS_BUILD_VAR=WOS_BUILD_VER_${DEVICE^^}
	LOS_BUILD_VERSION=${!WOS_BUILD_VAR}
	LOS_DEVICE=`echo $DEVICE | sed 's/_.*//'`

	# Versions prior to 21 of LineageOS use a common security version number, check to see if it
	# exists for this build version
	if [ -f "/home/WundermentOS/android/lineage-$LOS_BUILD_VERSION/build/core/version_defaults.mk" ]
	then
		grep "PLATFORM_SECURITY_PATCH :=" ~/android/lineage-$LOS_BUILD_VERSION/build/core/version_defaults.mk > ~/devices/$DEVICE/status/current.security.patch.txt
	fi

	# Version 21 of LineageOS uses the newer build_config system and a different flag.
	if [ -f "/home/WundermentOS/android/lineage-$LOS_BUILD_VERSION/build/release/build_config/ap2a.scl" ]
	then
		grep "RELEASE_PLATFORM_SECURITY_PATCH" ~/android/lineage-$LOS_BUILD_VERSION/build/release/build_config/ap2a.scl > ~/devices/$DEVICE/status/current.security.patch.txt
	fi

	# Version 22.1 of LineageOS uses the newer build_config system and a different flag.
	if [ -f "/home/WundermentOS/android/lineage-$LOS_BUILD_VERSION/build/release/flag_values/ap4a/RELEASE_PLATFORM_SECURITY_PATCH.textproto" ]
	then
		grep "string_value:" ~/android/lineage-$LOS_BUILD_VERSION/build/release/flag_values/ap4a/RELEASE_PLATFORM_SECURITY_PATCH.textproto > ~/devices/$DEVICE/status/current.security.patch.txt
	fi

	# Version 22.2 of LineageOS uses the newer build_config system and a different flag in a different location.
	if [ -f "/home/WundermentOS/android/lineage-$LOS_BUILD_VERSION/build/release/flag_values/bp1a/RELEASE_PLATFORM_SECURITY_PATCH.textproto" ]
	then
		grep "string_value:" ~/android/lineage-$LOS_BUILD_VERSION/build/release/flag_values/bp1a/RELEASE_PLATFORM_SECURITY_PATCH.textproto > ~/devices/$DEVICE/status/current.security.patch.txt
	fi

	# Version 23.0 of LineageOS uses the newer build_config system like 22.2 but has a new flag.
	if [ -f "/home/WundermentOS/android/lineage-$LOS_BUILD_VERSION/vendor/lineage/release/flag_values/bp2a/RELEASE_PLATFORM_SECURITY_PATCH.textproto" ]
	then
		grep "string_value:" ~/android/lineage-$LOS_BUILD_VERSION/vendor/lineage/release/flag_values/bp2a/RELEASE_PLATFORM_SECURITY_PATCH.textproto > ~/devices/$DEVICE/status/current.security.patch.txt
	fi

	# Let's see if we've had a security patch update since yesterday.
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
