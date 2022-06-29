#!/bin/bash

if [ "$1" == "" ]; then
	echo "Usage: sign-zip.sh filename"
else
	if [ -f $1 ]; then
		# Get the filename with the zip extension.
		filename="${1%.*}"

		# Align the zip file so it signs correctly.
		zipalign -v -p 4 $filename.zip $filename.aligned.zip

		# Signing with the release key.
		signapk -w --min-sdk-version 21 ~/.android-certs/releasekey.x509.pem ~/.android-certs/releasekey.pk8 $filename.aligned.zip $filename.signed.zip

		# Cleanup!
		rm $filename.aligned.zip
		mv $filename.zip $filename.orig.zip
		mv $filename.signed.zip $filename.zip
	else
		echo "ERROR: Zip file ($1) not found!"
	fi
fi
