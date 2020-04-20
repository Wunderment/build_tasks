#!/bin/bash

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
        LOSDIRNAME=$(basename $LOSPATHNAME)

	cd ~/android/$LOSDIRNAME/packages/apps/Jelly/app/src/main/res/values

	sed 's/https:\/\/google\.com\/search?ie=UTF-8&amp;source=android-browser&amp;q={searchTerms}/https:\/\/duckduckgo.com\/?q={searchTerms}/' strings.xml > strings.xml.new
	sed 's/https:\/\/google\.com/https:\/\/start.duckduckgo.com/' strings.xml.new > strings.xml
	sed 's/GOOGLE/DUCK/' strings.xml > strings.xml.new
	cp strings.xml.new strings.xml
	rm strings.xml.new
done
