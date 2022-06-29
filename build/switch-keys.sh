#!/bin/bash

if [ "$1" == "" ]; then
	# Assuming no command line options, swap which keys we're using.
	if [ -d ~/.android-certs-2048 ]; then
		echo -n "Switching to 2048 bit signing keys..."
		mv ~/.android-certs ~/.android-certs-4096
		mv ~/.android-certs-2048 ~/.android-certs
		echo "done."
	else
		echo -n "Switching to 4096 bit signing keys..."
		mv ~/.android-certs ~/.android-certs-2048
		mv ~/.android-certs-4096 ~/.android-certs
		echo "done."
	fi
else
	# Switch to desired key type.
	if [ "$1" == "2048" ]; then
		# Check to see if the 2048 directory exists, if so then we're using the 4096 currently and we need to switch.
		if [ -d ~/.android-certs-2048 ]; then
			echo -n "Switching to 2048 bit signing keys..."
			mv ~/.android-certs ~/.android-certs-4096
			mv ~/.android-certs-2048 ~/.android-certs
			echo "done."
		else
			echo "2048 bit signing keys already set."
		fi
	elif [ "$1" == "4096" ]; then
		# Check to see if the 4096 directory exists, if so then we're using the 2048 currently and we need to switch.
		if [ -d ~/.android-certs-4096 ]; then
			echo -n "Switching to 4096 bit signing keys..."
			mv ~/.android-certs ~/.android-certs-2048
			mv ~/.android-certs-4096 ~/.android-certs
			echo "done."
		else
			echo "4096 bit signing keys already set."
		fi
	else
		echo "Error: Unrecognized option; Usage: switch-keys.sh [2048/4096]"
	fi
fi