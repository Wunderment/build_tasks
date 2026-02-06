#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have, but only do 21.0 and above.
for LOSVERSION in 21.0 22.0 22.1 22.2 23.0 23.1 23.2; do
	for LOSPATHNAME in ~/android/lineage-$LOSVERSION; do
		LOSDIRNAME=$(basename $LOSPATHNAME)

		if [ -d "$LOSPATHNAME" ]; then
			if grep "//  return yes_no(device" recovery.cpp > /dev/null; then
				echo "Patch already applied to $LOSPATHNAME."
			else
				echo "Removing reboot from recovery when sideloading for $LOSPATHNAME..."

				# Loop through all the various languages.
				cd $LOSPATHNAME/bootable/recovery
				patch recovery.cpp ~/tasks/source/recovery_remove_ab_reboot-$LOSVERSION.patch
			fi
		fi
	done

done