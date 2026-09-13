#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)
	LOSVERSION=$(echo $LOSDIRNAME | sed 's|.*-||')
	LOSMAJOR=$(echo $LOSVERSION | sed 's|\..*||')

	# Patch only version of Lineage above 22 as that is when the deny list was introduced.
	if (( $LOSMAJOR >= 23 )); then
		echo -n "Patching android.mk deny list $LOSDIRNAME... "

		cd $LOSPATHNAME/build/soong/ui/build

		# Check to see if we need to patch the updater before doing so.
		if grep "//\"packages/\"," androidmk_denylist.go > /dev/null; then
			patch androidmk_denylist.go ~/tasks/source/androidmk_denylist.go-$LOSVERSION.patch
			echo "done."
		else
			echo "already patched."
		fi
	fi
done