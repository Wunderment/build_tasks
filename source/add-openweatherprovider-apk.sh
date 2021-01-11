#!/bin/bash

# Note: At this time OWP is not supported in LOS 17.1 or later.

# Check to see if the lineage 16.0 directory exists before doing anything else.
if [[ -d ~/android/lineage-16.0 ]]; then

	cd ~/android/lineage-16.0/packages/apps
	mkdir OpenWeatherProvider

	cp ~/tasks/source/OpenWeatherProvider-Android.mk ~/android/lineage-16.0/packages/apps/F-Droid/Android.mk
	cp ~/android/openweathermapprovider/OpenWeatherProvider.apk ~/android/lineage-16.0/packages/apps/OpenWeatherProvider
fi