#!/bin/bash

cd ~/android/lineage/vendor/lineage/config

# First let's check to make sure we haven't already updated the buildinfo.sh.
grep "F-Droid" common.mk > /dev/null
RET=$?

if [ $RET -eq 1 ]; then
	echo "Adding Wunderment build items to Lineage's common.mk..."

	# Concatenate the two chuncks back togheter.
	cat ~/tasks/source/lineage.common.mk >> common.mk

	echo "Done!"

	exit
fi

echo "Wunderment build items already existin in Lineage's common.mk!"
