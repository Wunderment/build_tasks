#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)
	LOSVERSION=$(echo $LOSDIRNAME | sed 's|.*-||')
	LOSMAJOR=$(echo $LOSVERSION | sed 's|\..*||')

	# Update the building process for pre-built images other than vendor, only supported on LOS 17+.
	if (( $LOSMAJOR >= 17 )); then
		echo -n "Patching Updater for $LOSDIRNAME... "
		cd $LOSPATHNAME/packages/apps/Updater/src/org/lineageos/updater/misc

		# Check to see if we need to patch the updater before doing so.
		if grep "SystemProperties.get(Constants.PROP_BUILD_VERSION));" Utils.java > /dev/null; then
			patch Utils ~/tasks/source/updater-canInstall-$LOSVERSION.patch
			echo "done."
		else
			echo "already patched."
		fi
	fi
done