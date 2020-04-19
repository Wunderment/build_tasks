#!/bin/bash

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	cd ~/android/$LOSDIRNAME/packages/apps/F-Droid

	rm -f FDroid.apk

	wget https://f-droid.org/FDroid.apk
done
