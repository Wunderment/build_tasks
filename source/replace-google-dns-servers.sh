#!/bin/bash

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	echo -n "Replacing Google DNS in $LOSPATHNAME... "

	# Replace the default Google DNS servers with Cloudfare's 1.1.1.1.
	cd $LOSPATHNAME/frameworks/base/core/res/res/values

	sed -i 's/4.4.4.4,8.8.8.8/1.1.1.1,1.0.0.1/' config.xml
	sed -i 's/8.8.8.8/1.1.1.1/' config.xml

	echo "done."
done

