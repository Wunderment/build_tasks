#!/bin/bash

# Go get the current f-droid apk.
cd ../unfiednlp
./get-networklocation-apk.sh

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	echo -n "Updating NetworkLocation APK for $LOSDIRNAME... "
	cd ~/android/$LOSDIRNAME/packages/apps/NetworkLocation

	rm -f NetworkLocation.apk

	cp ~/tasks/unifiednlp/current-networklocation.apk NetworkLocation.apk

	echo "done."
done
