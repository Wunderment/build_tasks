#!/bin/bash

# Go get the current f-droid apk.
cd ../f-droid
./get-f-droid-apk.sh

# Come back to the source directory.
cd ../source

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	if [[ ! -d ~/android/$LOSDIRNAME/packages/apps/F-Droid ]]; 	then
		echo -n "Adding F-Droid to $LOSDIRNAME..."
		cd ~/android/$LOSDIRNAME/packages/apps

		mkdir F-Droid

		cd F-Droid

		cp ~/tasks/source/F-Droid-Android.mk ~/android/$LOSDIRNAME/packages/apps/F-Droid/Android.mk
		cp ~/tasks/f-droid/current-f-droid.apk F-Droid.apk

		echo "done."
	fi
done
