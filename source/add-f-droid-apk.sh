#!/bin/bash

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
        LOSDIRNAME=$(basename $LOSPATHNAME)

	cd ~/android/$LOSDIRNAME/packages/apps
	mkdir F-Droid

	cp ~/tasks/source/F-Droid-Android.mk ~/android/$LOSDIRNAME/packages/apps/F-Droid/Android.mk

	wget https://f-droid.org/FDroid.apk
	mv FDroid.apk F-Droid.apk
done
