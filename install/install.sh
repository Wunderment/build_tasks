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

# Setup the android directory.
cd ~/android
mkdir lineage-17.1
mkdir lineage-18.1
mkdir lineage-19.1

# Setup the bin directory.
cd ~/bin

# Download sdat2img from https://github.com/xpirt/sdat2img.
wget -q -O sdat2img.py https://raw.githubusercontent.com/xpirt/sdat2img/master/sdat2img.py
wget -q -O sdat2img.README.md https://raw.githubusercontent.com/xpirt/sdat2img/master/README.md

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

echo "export WOS_DEVICES=\"lemonade_18\"" > devices.sh
echo "" > devices.sh
echo "# OnePlus 5"
echo "export WOS_BUILD_VER_DUMPLING_17=\"17.1\"" > devices.sh
echo "export WOS_BUILD_VER_DUMPLING_18=\"18.1\"" > devices.sh
echo ""
echo "# OnePlus 6"
echo "export WOS_BUILD_VER_ENCHILADA_17=\"17.1\"" > devices.sh
echo "export WOS_BUILD_VER_ENCHILADA_18=\"18.1\"" > devices.sh
echo ""
echo "# OnePlus 6T"
echo "export WOS_BUILD_VER_FAJITA_17=\"17.1\"" > devices.sh
echo "export WOS_BUILD_VER_FAJITA_18=\"18.1\"" > devices.sh
echo ""
echo "# OnePlus 7 Pro"
echo "export WOS_BUILD_VER_GUACAMOLE_18=\"18.1\"" > devices.sh
echo ""
echo "# OnePlus 7"
echo "export WOS_BUILD_VER_GUACAMOLEB_17=\"17.1\"" > devices.sh
echo ""
echo "# OnePlus 8T"
echo "export WOS_BUILD_VER_KEBAB_18=\"18.1\"" > devices.sh
echo ""
echo "# Google Pixel 4"
echo "export WOS_BUILD_VER_FLAME_18=\"18.1\"" > devices.sh
echo ""
echo "# Samsung Galaxy Tab S5e"
echo "export WOS_BUILD_VER_GTS4LVWIFI_17=\"17.1\"" > devices.sh
echo "export WOS_BUILD_VER_GTS4LVWIFI_18=\"18.1\"" > devices.sh
echo ""
echo "# Android Studio Emulator"
echo "export WOS_BUILD_VER_LINEAGE_X86_17=\"17.1\"" > devices.sh

echo "export WOS_LOGDEST=\"root\"" > log-email-address.sh

chmod +x *.sh

