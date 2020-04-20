#!/bin/bash

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
        LOSDIRNAME=$(basename $LOSPATHNAME)

	cd ~/android/$LOSDIRNAME/vendor/lineage/config

	# First let's check to make sure we haven't already updated the buildinfo.sh.
	grep "F-Droid" common.mk > /dev/null
	RET=$?

	if [ $RET -eq 1 ]; then
		echo "Adding Wunderment build items to $LOSDIRNAME's common.mk..."

		# Concatenate the two chuncks back togheter.
		cat ~/tasks/source/$LOSDIRNAME.common.mk >> common.mk

		echo "Done!"

		continue
	fi

	echo "Wunderment build items already existin in $LOSDIRNAME's common.mk!"
done
