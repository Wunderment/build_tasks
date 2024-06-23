#!/bin/bash

STARTTIME=`date +%s`

# Source our global build functions.
source ~/tasks/build/global-build-functions.sh

DOBUILD=false
DOCLEAN=false
DOFG=false
DOLOG=false
DONOHUP=false
DOSIGN=false
HAVEACTION=false

# Replace any dashes with spaces and convert everything to lowercase.
PARAMETERS=$(echo $@ | sed 's/-/ /' | awk '{print tolower($VAR)}')

# Convert any of the old underscores parameters to the new style
PARAMETERS=$(echo $PARAMETERS | sed 's/build_only/build/')
PARAMETERS=$(echo $PARAMETERS | sed 's/build_sign/build sign/')
PARAMETERS=$(echo $PARAMETERS | sed 's/clean_build_sign/clean build sign/')
PARAMETERS=$(echo $PARAMETERS | sed 's/nohup_build/nohup build/')
PARAMETERS=$(echo $PARAMETERS | sed 's/nohup_build_sign/nohup build sign/')

IFS=' ' read -ra PARRAY <<< "$PARAMETERS"

for OPTION in "${PARRAY[@]}"
do
	case $OPTION in
		build)
			HAVEACTION=true
			DOBUILD=true
			;;
		clean)
			HAVEACTION=true
			DOCLEAN=true
			;;
		foreground)
			DOFG=true
			;;
		log)
			DOLOG=true
			;;
		nohup)
			DONOHUP=true
			DOLOG=true
			;;
		sign)
			HAVEACTION=true
			DOSIGN=true
			;;
		*)
			DEVICE=$OPTION
			;;
	esac
done

# Check to see if we've been told to run in the background.
if [ "$DONOHUP" == "true" ]; then
	# Remove the nohup parameter
	PARAMETERS=$(echo $PARAMETERS | sed 's/nohup//')

	# Recall this script and disown it.
	$0 $PARAMETERS < /dev/null &> /dev/null & disown
	exit 0
fi

# We need at least 2 command line parameters to work.
if [ $# -le 1 ]; then
	echo "Incorrect parameters supplied!"
	help_screen

 	exit 1
fi

# We need at 1 action to do.
if [ "$HAVEACTION" == "false" ]; then
	echo "No action specified!"
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

# A device name may have a special case where we're building multiple versions, like for LOS 16
# and 17.  In these cases an extra modifier on the device name is added that starts with a '_'
# so for example dumpling_17 to indicate to build LOS 17 for dumpling.  In these cases we need
# to leave the modifier on $DEVICE so logs and other commands are executed in the right directory
# but for the actual LOS build, we need to strip it off.  So do so now.
LOS_DEVICE=`echo $DEVICE | sed 's/_.*//'`

# Create shell variables for the out directory and the final package name.
OUT=~/android/lineage-$LOS_BUILD_VERSION/out/target/product/$LOS_DEVICE
PKGNAME=WundermentOS-$LOS_BUILD_VERSION-$TODAY-release-$LOS_DEVICE-signed

# Add the LOS build tools path to the environment.
# Note: Android 11 and above put all their tools in the out directory, where as Android 10 and
#       below leave them in the build directory, so add the build directory after the out directory.
export PATH=$PATH:~/android/lineage-$LOS_BUILD_VERSION/out/host/linux-x86:~/android/lineage-$LOS_BUILD_VERSION/out/host/linux-x86/bin:~/android/lineage-$LOS_BUILD_VERSION/build/make/tools/releasetools:~/android/lineage-$LOS_BUILD_VERSION/out/soong/host/linux-x86/bin

# Add the LOS java library paths to the environment.
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/android/lineage-$LOS_BUILD_VERSION/out/host/linux-x86/lib:~/android/lineage-$LOS_BUILD_VERSION/out/host/linux-x86/lib64

# Add the release type, required after March 2024 security update.
# ap1a = QPR2
# ap2a = QPR3
export TARGET_RELEASE=ap2a

# Make sure we're in the build directory.
cd ~/tasks/build

# Setup the logging as requested.
if [ "$DOLOG" == "true" ]; then
	# Create a string to describe what we're doing
	if [ "$DOCLEAN" == "true" ]; then
		ACTIONS="clean"
	fi
	if [ "$DOBUILD" == "true" ]; then
		ACTIONS="$ACTIONS-build"
	fi
	if [ "$DOSIGN" == "true" ]; then
		ACTIONS="$ACTIONS-sign"
	fi

	# Remove any unneeded slashes
	ACTIONS=$(echo $ACTIONS | sed 's|--|-|g' | sed 's|^-||g' | sed 's|-$||g')

	OUTDEV=~/devices/$DEVICE/logs/$ACTIONS-wundermentos.log

	# Clear/create the log file
	echo "" > $OUTDEV

	# Send an email to indicate the start of the actions.
	echo "Actions started for $DEVICE..." | mail -s "WundermentOS $ACTIONS started for $DEVICE..." $WOS_LOGDEST
else
	OUTDEV=/dev/stdout
fi

# Start to do the actions we've been told to, starting with clean.
if [ "$DOCLEAN" == "true" ]; then
	echo "Clean started for $DEVICE..." >> $OUTDEV

	clean_wos >> $OUTDEV 2>&1
fi

# Next, run the build action if selected.
if [ "$DOBUILD" == "true" ]; then
	echo "Build started for $DEVICE..." >> $OUTDEV

	build_wos >> $OUTDEV 2>&1
fi

# Next, run the sign action if selected.
if [ "$DOSIGN" == "true" ]; then
	echo "Sign started for $DEVICE..." >> $OUTDEV

	sign_wos >> $OUTDEV 2>&1

	# Since we're creating a proper OTA, let's validate it against the last build
	# and see if we're within 1% of the file size, if not, there might be something
	# wrong and so we're throw a warning.
	validate_release_size
fi

#Finally, output the closing messages and send the log.
if [ "$DOSIGN" == "true" ] || [ "$DOBUILD" == "true" ] || [ "$DOCLEAN" == "true" ]; then
	ENDTIME=`date +%s`
	DURATION=$((ENDTIME-STARTTIME))

	echo "Elapsed time: $((DURATION / 60)):$((DURATION % 60))" >> $OUTDEV

	# Send output to the log if selected
	if [ $DOLOG == "true" ]; then
		send_build_sign_log
	fi
fi
