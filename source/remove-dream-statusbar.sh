#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have, but only do 23.2 and above as it was added in QRP2.
for LOSVERSION in 23.2 24.0; do
	for LOSPATHNAME in ~/android/lineage-$LOSVERSION; do
		LOSDIRNAME=$(basename $LOSPATHNAME)
		cd $LOSPATHNAME/frameworks/base/packages/SystemUI/src/com/android/systemui/ambient/statusbar/ui/

		if [ -d "$LOSPATHNAME" ]; then
			if grep "/*        return (!mDreamOverlayStateController.isLowLightActive()" AmbientStatusBarViewController.java > /dev/null; then
				echo "Patch already applied to $LOSPATHNAME."
			else
				echo "Removing status bar when dreaming for $LOSPATHNAME..."

				# Loop through all the various languages.
				patch AmbientStatusBarViewController.java ~/tasks/source/DreamStatusBar-$LOSVERSION.patch
			fi
		fi
	done

done
