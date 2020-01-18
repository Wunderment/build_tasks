#!/bin/bash

# Source some functions we'll use later.
source ~/tasks/build/build-functions.sh

# Set our options from the command line, even if they're wrong, we'll check them next.
WOS_BUILD_TYPE=$1
DEVICE=$2

# We need at least 2 command line parameters to work.
if [ $# -le 1 ]; then
	echo "Incorrect parameter supplied!"
	help_screen

 	exit 1
fi

# We cant' have more than 2 command line parameters to work.
if [ $# -ge 3 ]; then
    	echo "Too many parameters supplied!"
    	help_screen

    	exit 1
fi

# Make sure the target device has a directory.
if [ ! -d ~/devices/$DEVICE ]; then
	echo "The specified device does not exist!"
    	exit 1
fi

# Import the destination e-mail address to send logs to.
source ~/.WundermentOS/log-email-address.sh

# Create a shell variable to hold today's date in YYYYMMDD format.
TODAY=$(date +"%Y%m%d")

# Create shell variables for the out directry and the final package name.
OUT=~/android/lineage/out/target/product/$DEVICE
PKGNAME=WundermentOS-16.0-$TODAY-release-$DEVICE-signed

# Make sure we're in the build directory.
cd ~/tasks/build

# Execute the build function the user has requested.
# Note: "build_wos" and "sign_wos" are functions defined in the build-functions.sh file and do the majority of the work.
case $WOS_BUILD_TYPE in
	build_only)
		echo "Build (only) started for $DEVICE..." | mail -s "WundermentOS Build (Only) Started for $DEVICE..." $WOS_LOGDEST

		build_wos > ~/devices/$DEVICE/logs/build-wundermentos.log 2>&1

		cat ~/devices/$DEVICE/logs/build-wundermentos.log | mail -s "WundermentOS Build (Only) Log for $DEVICE" $WOS_LOGDEST
		;;
	build_sign)
		echo "Build started for $DEVICE..." | mail -s "WundermentOS Build Started for $DEVICE..." $WOS_LOGDEST

		build_wos > ~/devices/$DEVICE/logs/build-sign-wundermentos.log 2>&1
		sign_wos > ~/devices/$DEVICE/logs/build-sign-wundermentos.log 2>&1

		cat ~/devices/$DEVICE/logs/build-sign-wundermentos.log | mail -s "WundermentOS Build Log for $DEVICE" $WOS_LOGDEST
		;;
	build)
		build_wos
		;;
	nohup_build)
		nohup ~/tasks/build/build.sh build_only $DEVICE > /dev/null 2>&1 &
		;;
	nohup_build_sign)
		nohup ~/tasks/build/build.sh build_sign $DEVICE > /dev/null 2>&1 &
		;;
	sign)
		sign_wos
		;;
	*)
		echo "Unknown action: $WOS_BUILD_TYPE"
		help_screen

		exit 1
		;;
esac
