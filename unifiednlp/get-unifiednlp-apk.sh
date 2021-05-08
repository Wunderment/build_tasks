#!/bin/bash

# Check to see if we've download the current apk in the last 240 minutes.
if test `find "current-networklocation.apk" -mmin +240`
then
	echo -n "Checking for new UnifiedNlp release... "

	# Get the web page for the f-droid apk.
	wget -q -O unifiednlp-releases.json https://api.github.com/repos/microg/UnifiedNlp/releases

	php get-unifiednlp.php

	rm unifiednlp-releases.json

	touch current-networklocation.apk
else
    echo "UnifiedNlp is already up to date (downloaded less than 240 minutes ago)."
fi
