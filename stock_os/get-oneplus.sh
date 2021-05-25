#!/bin/bash

# Get the device name from the parent directory of this script's real path.
DEVICE=$(basename $(dirname $(dirname $(realpath $0))))

# A device name may have a special case where we're building multiple versions, like for LOS 16
# and 17.  In these cases an extra modifier on the device name is added that starts with a '_'
# so for example dumpling_17 to indicate to build LOS 17 for dumpling.  In these cases we need
# to leave the modifier on $DEVICE so logs and other commands are executed in the right directory
# but for the actual LOS build, we need to strip it off.  So do so now.
LOS_DEVICE=`echo $DEVICE | sed 's/_.*//'`

# Make sure we're in the stock os directory.
cd ~/devices/$DEVICE/stock_os

# Remove the old json file before we download the new one.
rm oneplus.json

# Setup some defaults
if [ "$PHONELOC" == "" ]; then
	PHONELOC=us
fi

if [ "$STOREURL" == "" ]; then
	STOREURL=https://storeapi-na.oneplus.com/xman/send-in-repair/find-phone-systems
fi

if [ "COOKIES" == "" ]; then
	COOKIES=refererstore=us_en; redirectedCountry=us_en;
fi

# Use curl to download the current info from OnePlus for this device.
curl "$STOREURL" --cookie "$COOKIES" -H 'content-type: multipart/form-data; boundary=----WebKitFormBoundaryx6kJsIUK0M2Dzl5d' --data-binary $'------WebKitFormBoundaryx6kJsIUK0M2Dzl5d\r\nContent-Disposition: form-data; name="storeCode"\r\n\r\n'"$PHONELOC"$'\r\n------WebKitFormBoundaryx6kJsIUK0M2Dzl5d\r\nContent-Disposition: form-data; name="phoneCode"\r\n\r\n'"$PHONECODE"$'\r\n------WebKitFormBoundaryx6kJsIUK0M2Dzl5d--\r\n' -o oneplus.json > /dev/null 2>&1

# Parse the json file and download/process if necessary.
php ~/tasks/stock_os/get-oos.php

