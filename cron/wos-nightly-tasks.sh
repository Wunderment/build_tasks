# Change in to the lineage build directory.
cd ~/android/lineage

# Get the device list.
source ~/.WundermentOS/devices.sh

# Update the source code from GitHub.
~/bin/repo sync --force-sync > ~/tasks/cron/logs/repo.sync.log 2>&1

# Find out how long ago the F-Droid apk was downloaded (in seconds).
LASTFD=$(expr `date +%s` - `stat -c %Z ~/android/lineage/packages/apps/F-Droid/FDroid.apk`)

for DEVICE in $WOS_DEVICES; do
	# Let's see if we've had a security patch update since yesterday.
	grep "PLATFORM_SECURITY_PATCH :=" ~/android/lineage/build/core/version_defaults.mk > ~/devices/$DEVICE/status/current.security.patch.txt
	diff ~/devices/$DEVICE/status/last.security.patch.txt ~/devices/$DEVICE/status/current.security.patch.txt > /dev/null 2>&1
	ret=$?
	if [ $ret -eq 1 ]
	then
   		cp ~/devices/$DEVICE/status/current.security.patch.txt ~/devices/$DEVICE/status/last.security.patch.txt

		# check to see if we should re-download Fx-Droid.apk before running the buiild.
		if [ $LASTFD -gt 86400 ]; then
			~/tasks/source/update-f-droid-apk.sh

			# Reset the LASTFD variable so we don't download FDroid.apk for each device we're building for.
			LASTFD=0
		fi

   		# Update blobs and firmware.
   		~/devices/$DEVICE/stock_os/get-stock-os.sh

   		# Update the F-Droi APK.
   		~/tasks/source/update-f-droid-apk.sh

   		# Start the build/sign process and send it to the background.
   		~/devices/$DEVICE/build/build.sh nohup_build_sign
	fi
done
