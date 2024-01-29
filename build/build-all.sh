#!/bin/bash

# Source the device list.
source ~/.WundermentOS/devices.sh

for DEVICE in $WOS_DEVICES; do
	echo "Building $DEVICE..."
	cd ~/devices/$DEVICE/build
	./build.sh build sign log
done
