#!/bin/bash

# Check to see if we've download the current apk in the last 240 minutes.
if test `find "current-f-droid.apk" -mmin +240`
then
    echo Checking for new F-Droid apk...

	# Get the web page for the f-droid apk.
	wget https://f-droid.org/en/packages/org.fdroid.fdroid/

	# Split the page based on the current suggested version.
	csplit index.html '/name="suggested"/'

	# We no longer need the index file.
	rm index.html

	# Split the page based on the download link section.
	csplit xx01 '/package-version-download/'

	# Split the page based on the Download text, this removes everything below the download URL for us.
	csplit xx01 '/Download APK/'

	# We no longer need the second hunk.
	rm xx01

	# Split the remaining lines in to separate files.
	split -l 1 xx00

	# We no longer need the first hunk.
	rm xx00

	# The third line of the file has the url on it, so rename it for more processing.
	mv xac new_url.txt

	# We no longer need the other lines, so delete the files.
	rm xa*

	# Time to cleanup the new url file and get ride of stuff we don't need.
	sed -i 's/\s*//' new_url.txt
	sed -i 's/<a href="//' new_url.txt
	sed -i 's/">//' new_url.txt

	# We now compare the newly processed url with the last one we downloaded and see if they're different.
	if ! diff new_url.txt url.txt > /dev/null; then
		# We need to download a new apk, so import the url we retrieved earlier in to a variable.
		FDROIDURL=$(<new_url.txt)

		# Remove the old apk.
		rm current-f-droid.apk

		# Download the new apk.
		wget -O current-f-droid.apk $FDROIDURL

		# Touch the file so it has the current time/date on it.
		touch current-f-droid.apk

		# Replace the old url file with the new url file.
		rm url.txt
		mv new_url.txt url.txt
	fi
else
	    echo F-Droid apk already up to date (downloaded less than 240 minutes ago).
fi
