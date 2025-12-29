#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have, but only do 19.1 and above.
for LOSVERSION in 19.1 20.0 21.0 22.0 22.1 22.2 23.0 23.1; do
	for LOSPATHNAME in ~/android/lineage-$LOSVERSION; do
		LOSDIRNAME=$(basename $LOSPATHNAME)

		echo "Rebranding LineageOS to WundermentOS in the settings for $LOSPATHNAME..."

		# Loop through all the various languages.
		for VALUESPATHNAME in $LOSPATHNAME/lineage-sdk/lineage/res/res/values*; do
			STRINGFILE=$VALUESPATHNAME/strings.xml

			# Check to see if a string file exists, if so, let's replace LineageOS with WundermentOS.
			if [ -f "$STRINGFILE" ]; then
				echo "    Processing string file: $STRINGFILE..."

				# -r is for extended regex, we only want to match lines that are strings, not comments or other lines.
				sed -ri 's/(<string.*>.*)LineageOS(.*)/\1WundermentOS\2/' $STRINGFILE
			fi
		done

	done

done
