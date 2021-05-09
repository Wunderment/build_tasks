# build_tasks
WundermentOS build scripts.

This repository contains the build and setup scripts for configuring a WundermentOS build server.

Pre-requisits:
1. An Ubuntu 18.04 based system installed and configured.
1. Git and other required tools for installing and building LineageOS.


Installation steps:
1. Create a new user on your system named WundermentOS
1. Login to the new user account
1. Checkout the WundermentOS build scripts in to the home directory of your user:
```
	git clone https://github.com/Wunderment/build_tasks.git tasks
```
1. run the installation script:
```
	~/tasks/install/install.sh
```

1. Checkout the LineageOS source code (for more complete instructions see the LineageOS wiki, ie. https://wiki.lineageos.org/devices/fajita/build):
```
	cd ~/android
	repo init -u https://github.com/LineageOS/android.git -b lineage-18.1 lineage-18.1
	cd lineage-18.1
	repo sync
```
1. Make the necessary changes to your Wunderment config by editing the following files:
```
	~/.WundermentOS/deploy-info.sh
	~/.WundermentOS/devices.sh
	~/.WundermentOS/log-email-address.sh
```

1. Create your LinageOS signing keys, see https://wiki.lineageos.org/signing_builds.html for details.
1. Update the F-Droid apk:
```
	~/tasks/source/update-f-droid-apk.sh
```
1. Update the UnifiedNlp apk:
```
	~/tasks/source/update-unifiednlp-apk.sh
```
1. Run the WundermentOS source.sh:
```
	~/tasks/source/source.sh
```
1. Rerun repo sync on LineageOS.

1. Checkout the Wunderment devices repo:
```
	cd ~/devices
	git clone https://github.com/Wunderment/build_devices.git
```
1. Update the firmware/blobs/stock os for each of your devices, ie:
```
	~/devices/[device]/stock_os/get-stock-os.sh
	~/devices/[device]/firmware/extract-stock-os-firmware.sh
	~/devices/[device]/blobs/extract-stock-os-blobs.sh
```
1. Run test builds and look for errors:
```
	cd ~/devices/[device]/build
	./build.sh build
```
1. Run test signing and look for errors:
```
	cd ~/devices/dumpling/build
	./build.sh sign
```
