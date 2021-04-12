#!/bin/bash

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	cd ~/android/$LOSDIRNAME/build/tools

	# First let's check to make sure we haven't already updated the buildinfo.sh.
	if ! grep "ota.wunderment.org" buildinfo.sh > /dev/null; then
		echo "Adding Wunderment OTA updater URL to $LOSDIRNAME buildinfo.sh..."

		sed -i 's/echo "# end build properties"/echo "# Set the updater URI"\necho "lineage.updater.uri=https:\/\/ota.wunderment.org\/api\/v1\/{device}\/{type}\/{incr}"\n\necho "# end build properties"/' buildinfo.sh

		echo "Done!"

		continue
	fi

	echo "Wunderment OTA updater URL already exists for $LOSDIRNAME!"
done