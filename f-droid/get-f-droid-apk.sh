#!/bin/bash

# Check to see if we've download the current apk in the last 240 minutes to avoid DOSing f-droid.
if test `find "current-f-droid.apk" -mmin +240`; then
	echo -n "Checking for new F-Droid apk... "

	# Delete the index file if it already exists for some reason.
	if [ -f index.html ]; then
		rm index.html
	fi

	# Get the web page for the f-droid apk and store it in index.html.
	wget -O index.html -q https://f-droid.org/en/packages/org.fdroid.fdroid/

	# Get the first url to the f-droid apk.
	grep -m 1 "https://f-droid.org/repo/org.fdroid.fdroid_.*.apk" index.html > new_url.txt

	# Time to cleanup the new url file and get ride of stuff we don't need.
	sed -i 's/\s*//' new_url.txt
	sed -i 's/<a href="//' new_url.txt
	sed -i 's/">//' new_url.txt

	# Delete the index file as it's no longer needed.
	rm index.html

	# Make sure we have at least an empty file to diff against.
	if ! [ -f url.txt ]; then
		cp /dev/null url.txt
	fi

	# We now compare the newly processed url with the last one we downloaded and see if they're different.
	if ! diff new_url.txt url.txt > /dev/null; then
		echo "new version found!"

		# We need to download a new apk, so import the url we retrieved earlier in to a variable.
		FDROIDURL=$(<new_url.txt)

		# Remove the old apk.
		rm current-f-droid.apk

		echo -n "Downloading new apk..."

		# Download the new apk.
		wget -q -O current-f-droid.apk $FDROIDURL

		echo "done!"

		# Replace the old url file with the new url file.
		rm url.txt
		mv new_url.txt url.txt
	else
		rm new_url.txt

	 	echo "F-Droid apk already up to date."
	fi

	# Touch the file so it has the current time/date on it.
	touch current-f-droid.apk
else
    echo "F-Droid apk already up to date (downloaded less than 240 minutes ago)."
fi
