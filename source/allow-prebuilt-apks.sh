#!/bin/bash

cd ~/tasks/source

# Update only for 22.1.
for LOSVERSION in 22.1 22.2; do
	for LOSPATHNAME in ~/android/lineage-$LOSVERSION; do
		LOSDIRNAME=$(basename $LOSPATHNAME)

		echo "Allowing prebuilt APKs in the packages directory for $LOSPATHNAME..."

		cd $LOSPATHNAME/build/soong/ui/build
		sed -ri 's/^\t\"packages\/\",/\t\/\/\"packages\/\",/' androidmk_denylist.go

	done

done
