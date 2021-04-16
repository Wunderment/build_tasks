#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	cd $LOSPATHNAME/build/tools

	# First let's check to make sure we haven't already updated the buildinfo.sh.
	if ! grep "ota.wunderment.org" buildinfo.sh > /dev/null; then
		echo -n "Adding Wunderment OTA updater URL to $LOSDIRNAME buildinfo.sh..."

		sed -i 's/echo "# end build properties"/echo "# Set the updater URI"\necho "lineage.updater.uri=https:\/\/ota.wunderment.org\/api\/v1\/{device}\/{type}\/{incr}"\n\necho "# end build properties"/' buildinfo.sh

		echo "done."
	else
		echo "Wunderment OTA updater URL already exists for $LOSDIRNAME."
	fi
done