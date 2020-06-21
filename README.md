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

1. Checkout the LineageOS 16.0 source code (for more complete instructions see the LinageOS wiki, ie. https://wiki.lineageos.org/devices/fajita/build):
```
	cd ~/android
	repo init -u https://github.com/LineageOS/android.git -b lineage-16.0 lineage-16.0
	cd lineage-16.0
	repo sync
	repo init -u https://github.com/LineageOS/android.git -b lineage-17.1 lineage-17.1
```
1. Checkout the LineageOS 17.0 source code (for more complete instructions see the LinageOS wiki, ie. https://wiki.lineageos.org/devices/fajita/build):
```
	cd ~/android
	repo init -u https://github.com/LineageOS/android.git -b lineage-17.1 lineage-17.1
	cd lineage-17.0
	repo sync
```
1. Make the necessary changes to your Wunderment Config by editing the following files:
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
1. Run the WundermentOS source.sh:
```
	~/tasks/source/source.sh
```
1. Rerun repo sync on all versions of LineageOS.

1. Update the firmware/blobs/stock os for each of your devices, ie:
```
	~/devices/dumpling/stock_os/get-stock-os.sh
	~/devices/dumpling/firmware/extract-stock-os-firmware.sh
	~/devices/dumpling/blobs/extract-stock-os-blobs.sh
```
	Note for each of the above scripts, there may be additional dependencies to mount various file
	systems to directoriese.  Review each of the scripts comments for things like:
```
        # Mount the system and vendor data.
        #
        # Note, these must appear in /etc/fstab otherwise we'd have to be root to moount them.  Use the following entires
        # in fstab to allow a user to mount them:
        #
        # /home/WundermentOS/devices/dumpling/blobs/system_dump/system.img /home/WundermentOS/devices/dumpling/blobs/system_dump/system auto defaults,noauto,user 0 1
        # /home/WundermentOS/devices/dumpling/blobs/system_dump/vendor.img /home/WundermentOS/devices/dumpling/blobs/system_dump/vendor auto defaults,noauto,user 0 1
        #
```
1. Run test builds and look for errors:
```
	cd ~/devices/dumpling/build
	./build.sh build
```
1. Run test signing and look for errors:
```
	cd ~/devices/dumpling/build
	./build.sh sign
```
1.Run final test build/sign:
```
	cd ~/devices/dumpling/build
	./build.sh build-sign
```
  This should deliver a completed log to the e-mail address you provided earlier.
