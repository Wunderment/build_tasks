#!/bin/bash

cd ~/android/lineage/build/tools

# First let's check to make sure we haven't already updated the buildinfo.sh.
grep "ota.wunderment.org" buildinfo.sh > /dev/null
RET=$?

if [ $RET -eq 1 ]; then
	echo "Adding Wunderment OTA updater URL to buildinfo.sh..."

	# Split the file in two just above the end line.
	csplit buildinfo.sh "/echo \"# end build properties\"/"
	
	# Add the OTA URL to the first chunk of the file.
	echo "echo \"# Set the updater URI\"" >> xx00
	echo "echo \"lineage.updater.uri=https://ota.wunderment.org/api/v1/{device}/{type}/{incr}\"" >> xx00
	echo "" >> xx00

	# Remove the old file.
	rm buildinfo.sh

	# Concatenate the two chuncks back togheter.
	cat xx00 xx01 > buildinfo.sh

	# Cleanup.
	rm xx00
	rm xx01

	echo "Done!"

	exit
fi

echo "Wunderment OTA updater URL already exists!"
