#!/bin/bash

cd ~/android/OpenWeatherProvider

zipalign -v -p 4 app-release-unsigned.apk app-release-unsigned-aligned.apk

apksigner sign --key ~/.android-certs/releasekey.pk8 --cert ~/.android-certs/releasekey.x509.pem --out OpenWeatherProvider.apk app-release-unsigned-aligned.apk

rm app-release-unsigned-aligned.apk

cp OpenWeatherProvider.apk ~/android/lineage/packages/apps/OpenWeatherProvider
