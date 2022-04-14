#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have, but only do 19.1 for now.
for LOSPATHNAME in ~/android/lineage-19*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	echo "Rebranding LineageOS to WundermentOS in the settings for $LOSPATHNAME..."

	# Loop through all the various languages.
	for VALUESPATHNAME in $LOSPATHNAME/lineage-sdk/lineage/res/res/values*; do
		STRINGFILE=$VALUESPATHNAME/strings.xml

		# Check to see if a string file exists, if so, let's replace LineageOS with WundermentOS.
		if [ -f "$STRINGFILE" ]; then
			echo "Processing string file: $STRINGFILE..."

			# -r is for extended regex, we only want to match lines that are strings, not comments or other lines.
			sed -ri 's/(<string.*>.*)LineageOS(.*)/\1WundermentOS\2/' $STRINGFILE
		fi
	done

done
