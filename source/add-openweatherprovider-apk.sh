#!/bin/bash

cd ~/android/lineage/packages/apps
mkdir OpenWeatherProvider

cp ~/tasks/source/OpenWeatherProvider-Android.mk ~/android/lineage/packages/apps/F-Droid/Android.mk
cp ~/android/openweathermapprovider/OpenWeatherProvider.apk ~/android/lineage/packages/apps/OpenWeatherProvider
