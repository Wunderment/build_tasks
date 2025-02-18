#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)
	LOSVERSION=$(echo $LOSDIRNAME | sed 's|.*-||')
	LOSMAJOR=$(echo $LOSVERSION | sed 's|\..*||')

	# Update the building process for pre-built images other than vendor, only supported on LOS 17+
	# but less than 22, as 22.1 added a build flag (lineage.updater.allow_major_upgrades) to support
	# the feature after February 17th, 2025.
	if (( $LOSMAJOR >= 17 && $LOSMAJOR < 22 )); then
		echo -n "Patching Updater for $LOSDIRNAME... "

		# Newer versions of LineageOS store the source in a different path, so check to see which
		# one we have and change to it.
		if [ -d "$LOSPATHNAME/packages/apps/Updater/src/org/lineageos/updater/misc" ]; then
			# LineageOS 20 July 2023 and older
			cd $LOSPATHNAME/packages/apps/Updater/src/org/lineageos/updater/misc
		else
			# LineageOS 20 July 8th 2023 and newer
			cd $LOSPATHNAME/packages/apps/Updater/app/src/main/java/org/lineageos/updater/misc
		fi

		# Check to see if we need to patch the updater before doing so.
		if grep "SystemProperties.get(Constants.PROP_BUILD_VERSION));" Utils.java > /dev/null; then
			patch Utils.java ~/tasks/source/updater-canInstall-$LOSVERSION.patch
			echo "done."
		else
			echo "already patched."
		fi
	fi
done