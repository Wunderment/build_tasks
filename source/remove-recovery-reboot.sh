#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have, but only do 21.0 and above.
for LOSVERSION in 21.0; do
	for LOSPATHNAME in ~/android/lineage-$LOSVERSION; do
		LOSDIRNAME=$(basename $LOSPATHNAME)

		echo "Removing reboot from recovery when sideloading for $LOSPATHNAME..."

		# Loop through all the various languages.
		cd $LOSPATHNAME/bootable/recovery
		patch recovery.cpp ~/tasks/source/recovery_remove_ab_reboot-21.0.patch
	done

done