#!/bin/bash

# Get the device name from the parent directory of this script's real path.
DEVICE=$(basename $(dirname $(dirname $(realpath $0))))

# A device name may have a special case where we're building multiple versions, like for LOS 16
# and 17.  In these cases an extra modifier on the device name is added that starts with a '_'
# so for example dumpling_17 to indicate to build LOS 17 for dumpling.  In these cases we need
# to leave the modifier on $DEVICE so logs and other commands are executed in the right directory
# but for the acutal LOS build, we need to strip it off.  So do so now.
LOS_DEVICE=`echo $DEVICE | sed 's/_.*//'`

# Make sure we're in the device's directory.
cd ~/devices/$DEVICE/stock_os

# Use curl to download the current info from Google for all Pixel devices.
curl https://developers.google.com/android/images -b "devsite_wall_acks=nexus-ota-tos,nexus-image-tos" > images.html

# Split the page based on the current device name version.
csplit images.html "/id=\"$LOS_DEVICE\"/" > /dev/null

# Split the page on the table layouts.
csplit xx01 '/<\/table>/' > /dev/null

# Cleanup and rename the part we want.
rm xx01
mv xx00 table.txt

# Split the table on rows.
csplit table.txt '/\<tr/' {*} > /dev/null

# We no longer need the full table.
rm table.txt

# The split on rows generated some number of individual rows, so we need to count them to find the last one.
SPLITCOUNT=`ls -1q xx* | wc -l`

# Then we need to subtract two from the total count; 1 for the zero based index of csplit, and 1 for the trailing tr.
SPLITTARGET=$(expr $SPLITCOUNT - 2)

# Now that we have identified the correct file, rename it for further processing.
mv xx$SPLITTARGET target.txt

# We no longer need the rest of the tr's.
rm xx*

# Split up the correct tr in to individual lines.
split -l 1 target.txt > /dev/null

# We no longer need target tr.
rm target.txt

# The url for download will be on the fourth line of the tr, so rename the matching file to our new release file.
mv xad new.stock.os.release.txt

# We no longer need any of the other lines.
rm xa*

# Time to cleanup the new url file and get ride of stuff we don't need.
sed -i 's/\s*//' new.stock.os.release.txt
sed -i 's/<td><a href="//' new.stock.os.release.txt
sed -i 's/"//' new.stock.os.release.txt

# We now compare the newly processed url with the last one we downloaded and see if they're different.
if ! diff new.stock.os.release.txt last.stock.os.release.txt > /dev/null; then
	echo Updating stock OS...

	# We need to download a stock os, so import the url we retrieved earlier in to a variable.
	STOCKURL=$(<new.stock.os.release.txt)

	# Remove the old stock os file.
	rm current-stock-os.zip

	# Download the new os file.
	wget -q -O current-stock-os.zip $STOCKURL

	# Replace the old url file with the new url file.
	rm last.stock.os.release.txt
	mv new.stock.os.release.txt last.stock.os.release.txt
else
	# If we don't need to download a new stock os, cleanup time.
	rm new.stock.os.release.txt

	echo No update needed.
fi

# Cleanup the images.html file as we're done.
rm images.html
