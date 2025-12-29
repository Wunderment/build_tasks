#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have, but only do 21.0 and above.
for LOSVERSION in 21.0 22.0 22.1 22.2 23.0 23.1; do
	for LOSPATHNAME in ~/android/lineage-$LOSVERSION; do
		LOSDIRNAME=$(basename $LOSPATHNAME)

		if ! grep "//  return yes_no(device" recovery.cpp > /dev/null; then
			echo "Removing reboot from recovery when sideloading for $LOSPATHNAME..."

			# Loop through all the various languages.
			cd $LOSPATHNAME/bootable/recovery
			patch recovery.cpp ~/tasks/source/recovery_remove_ab_reboot-$LOSVERSION.patch
		else
			echo "Patch already applied."
		fi
	done

done