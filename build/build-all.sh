#!/bin/bash

# Source the device list.
source ~/.WundermentOS/devices.sh

for DEVICE in $WOS_DEVICES; do
	cd ~/devices/$DEVICE/build
	./build.sh clean build sign log
done
