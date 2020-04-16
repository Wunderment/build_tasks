#!/bin/bash

echo "Installing Wunderment build system..."

if [ $user != "WundermentOS" ]; then
	echo "ERROR: not logged in as WundermentOS user... aborting!"

	exit 1
fi

# Create the top level directories.
cd ~
mkdir android
mkdir bin
mkdir releases
mkdir .android-certs
mkdir .WundermentOS

# Checkout the devices tree.
git clone https://github.com/Wunderment/build_devices.git devices

# Make the working directories we need for the blob and firmware update scripts.
foreach DEVICE in `find . -maxdepth 1 -mindepth 1 -type d`; do
	mkdir ~/devices/$DEVICE/blobs/system_dump
	mkdir ~/devices/$DEVICE/firmware/ota
	mkdir ~/devices/$DEVICE/firmware/update/firmware-update
	mkdir ~/devices/$DEVICE/firmware/update/RADIO
	mkdir ~/devices/$DEVICE/firmware/update/META-INF
	mkdir ~/devices/$DEVICE/firmware/update/META-INF/com
	mkdir ~/devices/$DEVICE/firmware/update/META-INF/com/google
	mkdir ~/devices/$DEVICE/firmware/update/META-INF/com/google/android
done

# Setup the android directory.
cd ~/android
mkdir lineage
mkdir OpenWeatherProvider

# Setup the bin directory.
cd ~/bin

# Download sdat2img from https://github.com/xpirt/sdat2img.
wget -O sdat2img.py https://raw.githubusercontent.com/xpirt/sdat2img/master/sdat2img.py
wget -O sdat2img.README.md https://raw.githubusercontent.com/xpirt/sdat2img/master/README.md

# Get the repo command.
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

# Setup the releases directory.
cd ~/releases
mkdir incremental
mkdir ota
mkdir signed_files

# Setup the .WundermentOS directory.
cd ~/.WundermentOS

echo "export WOS_USER=\"\""  > deploy-info.sh
echo "export WOS_PASS=\"\"" >> deploy-info.sh
echo "export WOS_HOST=\"\"" >> deploy-info.sh
echo "export WOS_DIR_FULL=\"ota.wunderment.org/builds/full\""

echo "export WOS_DEVICES=\"dumpling\"" > devices.sh

echo "export WOS_LOGDEST=\"root\"" > log-email-address.sh

chmod +x *.sh

