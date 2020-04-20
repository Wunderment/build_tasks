#!/bin/bash

# Note: At this time OWP is not supported in LOS 17.1.

cd ~/android/lineage-16.0/packages/apps
mkdir OpenWeatherProvider

cp ~/tasks/source/OpenWeatherProvider-Android.mk ~/android/lineage-16.0/packages/apps/F-Droid/Android.mk
cp ~/android/openweathermapprovider/OpenWeatherProvider.apk ~/android/lineage-16.0/packages/apps/OpenWeatherProvider
