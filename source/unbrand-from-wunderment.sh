#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have, but only do 19.1 for now.
for LOSPATHNAME in ~/android/lineage-19*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	echo "Umbranding LineageOS from WundermentOS in the settings for $LOSPATHNAME..."

	# Loop through all the various languages.
	for VALUESPATHNAME in $LOSPATHNAME/lineage-sdk/lineage/res/res/values*; do
		cd $VALUESPATHNAME
		git checkout strings.xml
		cd ..
	done

done
