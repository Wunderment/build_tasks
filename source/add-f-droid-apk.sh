#!/bin/bash

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	if [[ ! -d ~/android/$LOSDIRNAME/packages/apps/F-Droid ]]; 	then
		echo "Adding F-Droid to $LOSDIRNAME..."
		cd ~/android/$LOSDIRNAME/packages/apps

		mkdir F-Droid

		cd F-Droid

		cp ~/tasks/source/F-Droid-Android.mk ~/android/$LOSDIRNAME/packages/apps/F-Droid/Android.mk

		wget https://f-droid.org/FDroid.apk
		mv FDroid.apk F-Droid.apk
	fi
done
