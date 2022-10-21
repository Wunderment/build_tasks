#!/bin/bash

# Go get the current NetworkLocation apk.
cd ../unifiednlp
./get-unifiednlp-apk.sh

# Come back to the source directory.
cd ../source

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	echo "Checking $LOSDIRNAME..."

	if [[ ! -d ~/android/$LOSDIRNAME/packages/apps/NetworkLocation ]]; 	then
		echo -n "Adding UnifiedNLP to $LOSDIRNAME..."
		cd ~/android/$LOSDIRNAME/packages/apps

		mkdir NetworkLocation

		cd NetworkLocation

		cp ~/tasks/source/NetworkLocation-Android.mk Android.mk
		cp ~/tasks/source/privapp_whitelist_unifiednlp.xml .
		cp ~/tasks/unifiednlp/current-networklocation.apk NetworkLocation.apk

		echo "done."
	fi
done
