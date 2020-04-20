#!/bin/bash

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
        LOSDIRNAME=$(basename $LOSPATHNAME)

	# Replace the default google DNS servers with Cloudfare's 1.1.1.1.
	cd ~/android/$LOSDIRNAME/frameworks/base/core/res/res/values

	sed 's/4.4.4.4,8.8.8.8/1.1.1.1,1.0.0.1/' config.xml > config.xml.new
	sed 's/8.8.8.8/1.1.1.1/' config.xml.new > config.xml

	rm config.xml.new
done

