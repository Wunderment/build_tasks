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
mkdir lineage-22.1

# Setup the bin directory.
if [ ! -d ~/bin ]; then
	mkdir ~/bin
fi
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
echo "export WOS_DIR_FULL=\"ota.wunderment.org/builds/full\"" >> deploy-info.sh
echo "export WOS_GITHUB_REPO=\"releases\"" >> deploy-info.sh

echo "export WOS_DEVICES=\"gts4lvwifi_22 oriole_22 panther_22 husky_22\"" > devices.sh
echo "" >> devices.sh

echo "# Configure which version of LOS is to be used for each device." >> devices.sh
echo "" >> devices.sh
echo "# OnePlus 5" >> devices.sh
echo "export WOS_BUILD_VER_DUMPLING_17=\"17.1\"" >> devices.sh
echo "export WOS_BUILD_VER_DUMPLING_18=\"18.1\"" >> devices.sh
echo "export WOS_BUILD_VER_DUMPLING_19=\"19.1\"" >> devices.sh
echo "export WOS_BUILD_VER_DUMPLING_20=\"20.0\"" >> devices.sh
echo "" >> devices.sh
echo "# OnePlus 6" >> devices.sh
echo "export WOS_BUILD_VER_ENCHILADA_17=\"17.1\"" >> devices.sh
echo "export WOS_BUILD_VER_ENCHILADA_18=\"18.1\"" >> devices.sh
echo "export WOS_BUILD_VER_ENCHILADA_19=\"19.1\"" >> devices.sh
echo "export WOS_BUILD_VER_ENCHILADA_20=\"20.0\"" >> devices.sh
echo "" >> devices.sh
echo "# OnePlus 6T" >> devices.sh
echo "export WOS_BUILD_VER_FAJITA_17=\"17.1\"" >> devices.sh
echo "export WOS_BUILD_VER_FAJITA_18=\"18.1\"" >> devices.sh
echo "export WOS_BUILD_VER_FAJITA_19=\"19.1\"" >> devices.sh
echo "export WOS_BUILD_VER_FAJITA_20=\"20.0\"" >> devices.sh
echo "" >> devices.sh
echo "# OnePlus 7 Pro" >> devices.sh
echo "export WOS_BUILD_VER_GUACAMOLE_18=\"18.1\"" >> devices.sh
echo "" >> devices.sh
echo "# OnePlus 7" >> devices.sh
echo "export WOS_BUILD_VER_GUACAMOLEB_17=\"17.1\"" >> devices.sh
echo "export WOS_BUILD_VER_GUACAMOLEB_18=\"18.1\"" >> devices.sh
echo "" >> devices.sh
echo "# OnePlus 8T" >> devices.sh
echo "export WOS_BUILD_VER_KEBAB_18=\"18.1\"" >> devices.sh
echo "" >> devices.sh
echo "# OnePlus 9" >> devices.sh
echo "export WOS_BUILD_VER_LEMONADE_18=\"18.1\"" >> devices.sh
echo "export WOS_BUILD_VER_LEMONADE_19=\"19.1\"" >> devices.sh
echo "" >> devices.sh
echo "# Google Pixel 4" >> devices.sh
echo "export WOS_BUILD_VER_FLAME_18=\"18.1\"" >> devices.sh
echo "export WOS_BUILD_VER_FLAME_19=\"19.1\"" >> devices.sh
echo "export WOS_BUILD_VER_FLAME_20=\"20.0\"" >> devices.sh
echo "" >> devices.sh
echo "# Google Pixel 5" >> devices.sh
echo "export WOS_BUILD_VER_REDFIN_19=\"19.1\"" >> devices.sh
echo "export WOS_BUILD_VER_REDFIN_20=\"20.0\"" >> devices.sh
echo "" >> devices.sh
echo "# Google Pixel 6" >> devices.sh
echo "export WOS_BUILD_VER_ORIOLE_20=\"20.0\"" >> devices.sh
echo "export WOS_BUILD_VER_ORIOLE_21=\"21.0\"" >> devices.sh
echo "export WOS_BUILD_VER_ORIOLE_22=\"22.1\"" >> devices.sh
echo "#export WOS_BUILD_VER_ORIOLE_22=\"22.2\"" >> devices.sh
echo "" >> devices.sh
echo "# Google Pixel 7" >> devices.sh
echo "export WOS_BUILD_VER_PANTHER_20=\"20.0\"" >> devices.sh
echo "export WOS_BUILD_VER_PANTHER_21=\"21.0\"" >> devices.sh
echo "export WOS_BUILD_VER_PANTHER_22=\"22.1\"" >> devices.sh
echo "" >> devices.sh
echo "# Google Pixel 8 Pro" >> devices.sh
echo "export WOS_BUILD_VER_HUSKY_21=\"21.0\"" >> devices.sh
echo "export WOS_BUILD_VER_HUSKY_22=\"22.1\"" >> devices.sh
echo "" >> devices.sh
echo "# Google Pixel 9 Pro XL" >> devices.sh
echo "export WOS_BUILD_VER_KOMODO_22=\"22.1\"" >> devices.sh
echo "" >> devices.sh
echo "# Samsung Galaxy Tab S5e" >> devices.sh
echo "export WOS_BUILD_VER_GTS4LVWIFI_17=\"17.1\"" >> devices.sh
echo "export WOS_BUILD_VER_GTS4LVWIFI_18=\"18.1\"" >> devices.sh
echo "export WOS_BUILD_VER_GTS4LVWIFI_19=\"19.1\"" >> devices.sh
echo "export WOS_BUILD_VER_GTS4LVWIFI_20=\"20.0\"" >> devices.sh
echo "export WOS_BUILD_VER_GTS4LVWIFI_21=\"21.0\"" >> devices.sh
echo "export WOS_BUILD_VER_GTS4LVWIFI_22=\"22.1\"" >> devices.sh
echo "" >> devices.sh
echo "# Android Studio Emulator" >> devices.sh
echo "export WOS_BUILD_VER_LINEAGE_X86_17=\"17.1\"" >> devices.sh
echo "" >> devices.sh

echo "export WOS_LOGDEST=\"root\"" > log-email-address.sh

chmod +x *.sh

