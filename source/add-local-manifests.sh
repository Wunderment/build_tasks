#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)
	LOSVERSION=$(echo $LOSDIRNAME | sed 's|.*-||')
	LOSMAJOR=$(echo $LOSVERSION | sed 's|\..*||')

	echo -n "Adding local manifests to $LOSDIRNAME... "

	# Copy over the local manifest files.
	echo -n "F-Droid... "
	cp ~/tasks/source/F-DroidPrivilegedExtension.xml ~/android/$LOSDIRNAME/.repo/local_manifests
	echo -n "Wunderment... "
	cp ~/tasks/source/Wunderment-Vendor.xml ~/android/$LOSDIRNAME/.repo/local_manifests

	# The Muppets are only needed for LinageOS 17+.
	if (( $LOSMAJOR >= 17 )); then
		echo -n "The Muppets... "

		# The Muppets changed it's repo system for LineageOS 20+
		if (( $LOSMAJOR <= 20 )); then
			cp ~/tasks/source/TheMuppets.xml ~/android/$LOSDIRNAME/.repo/local_manifests
		else
			cp ~/tasks/source/TheMuppets-20.0.xml ~/android/$LOSDIRNAME/.repo/local_manifests/TheMuppets.xml
		fi
	fi

	echo "done."
done