#!/bin/bash

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	echo -n "Replacing Google NTP in $LOSPATHNAME... "

	# Replace the default Google NTP servers.
	cd $LOSPATHNAME/frameworks/base/core/res/res/values

	sed -i 's/time\.android\.com/pool.ntp.org/' config.xml

	echo "done."
done

