#!/bin/bash

STARTTIME=`date +%s`

# Source our global build functions.
source ~/tasks/build/global-build-functions.sh

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
	echo "The specified device ($DEVICE) does not exist!"
	exit 1
fi

# Source the device list.
source ~/.WundermentOS/devices.sh

# Source the build functions for this device.
source ~/devices/$DEVICE/build/device-build-functions.sh

# Import the destination e-mail address to send logs to.
source ~/.WundermentOS/log-email-address.sh

# Create a shell variable to hold today's date in YYYYMMDD format.
TODAY=$(date +"%Y%m%d")

# Find out which version of LinageOS we're going to build for this device.
WOS_BUILD_VAR=WOS_BUILD_VER_${DEVICE^^}
LOS_BUILD_VERSION=${!WOS_BUILD_VAR}

# Make sure we have a target LOS version.
if [ -z "$LOS_BUILD_VERSION" ]; then
	echo "The specified device ($DEVICE) does not have a build version!"
	exit 1
fi

# A device name may have a special case where we're building multiple versios, like for LOS 16
# and 17.  In these cases an extra modifier on the device name is added that starts with a '_'
# so for example dumpling_17 to indicate to build LOS 17 for dumpling.  In these cases we need
# to leave the modifier on $DEVICE so logs and other commands are executed in the right directory
# but for the acutal LOS build, we need to strip it off.  So do so now.
LOS_DEVICE=`echo $DEVICE | sed 's/_.*//'`

# Create shell variables for the out directry and the final package name.
OUT=~/android/lineage-$LOS_BUILD_VERSION/out/target/product/$LOS_DEVICE
PKGNAME=WundermentOS-$LOS_BUILD_VERSION-$TODAY-release-$LOS_DEVICE-signed

# Make sure we're in the build directory.
cd ~/tasks/build

# Execute the build function the user has requested.
# Note: "build_wos" and "sign_wos" are functions defined in the global-build-functions.sh file and do the majority of the work.
case $WOS_BUILD_TYPE in
	build_only|build-only)
		echo "Build (only) started for $DEVICE..." | mail -s "WundermentOS Build (Only) Started for $DEVICE..." $WOS_LOGDEST

		build_wos > ~/devices/$DEVICE/logs/build-wundermentos.log 2>&1

		ENDTIME=`date +%s`
		DURATION=$((ENDTIME-STARTTIME))
		echo "Elapsed time: $((DURATION / 60)):$((DURATION % 60))" >> ~/devices/$DEVICE/logs/build-wundermentos.log

		send_build_sign_log
		;;
	build_sign|build-sign)
		echo "Build started for $DEVICE..." | mail -s "WundermentOS Build Started for $DEVICE..." $WOS_LOGDEST

		build_wos > ~/devices/$DEVICE/logs/build-sign-wundermentos.log 2>&1
		sign_wos >> ~/devices/$DEVICE/logs/build-sign-wundermentos.log 2>&1

		ENDTIME=`date +%s`
		DURATION=$((ENDTIME-STARTTIME))
		echo "Elapsed time: $((DURATION / 60)):$((DURATION % 60))" >> ~/devices/$DEVICE/logs/build-sign-wundermentos.log

		send_build_sign_log
		;;
	build)
		build_wos
		;;
	nohup_build|nohup-build)
		nohup ~/tasks/build/build.sh build_only $DEVICE > /dev/null 2>&1 &
		;;
	nohup_build_sign|nohup-build-sign)
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
