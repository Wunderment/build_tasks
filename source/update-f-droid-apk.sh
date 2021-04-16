#!/bin/bash

# Go get the current f-droid apk.
cd ../f-droid
./get-f-droid-apk.sh

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	echo -n "Updating F-Droid APK for $LOSDIRNAME... "
	cd ~/android/$LOSDIRNAME/packages/apps/F-Droid

	rm -f F-Droid.apk

	cp ~/tasks/f-droid/current-f-droid.apk F-Droid.apk

	echo "done."
done
