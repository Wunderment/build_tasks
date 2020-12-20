#!/bin/bash

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
        LOSDIRNAME=$(basename $LOSPATHNAME)

	cd ~/android/$LOSDIRNAME/build/tools

	# First let's check to make sure we haven't already updated the buildinfo.sh.
	if ! grep "ota.wunderment.org" buildinfo.sh > /dev/null; then
		echo "Adding Wunderment OTA updater URL to $LOSDIRNAME buildinfo.sh..."

		# Split the file in two just above the end line.
		csplit buildinfo.sh "/echo \"# end build properties\"/"
	
		# Add the OTA URL to the first chunk of the file.
		echo "echo \"# Set the updater URI\"" >> xx00
		echo "echo \"lineage.updater.uri=https://ota.wunderment.org/api/v1/{device}/{type}/{incr}\"" >> xx00
		echo "" >> xx00

		# Remove the old file.
		rm buildinfo.sh

		# Concatenate the two chunks back together.
		cat xx00 xx01 > buildinfo.sh

		# Cleanup.
		rm xx00
		rm xx01

		echo "Done!"

		continue	
	fi

	echo "Wunderment OTA updater URL already exists for $LOSDIRNAME!"
done
