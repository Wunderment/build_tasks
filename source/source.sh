#!/bin/bash

cd ~/tasks/source

# Add the new local manifests to repo.
./add-local-manifests.sh

# Update the common.mk items (F-Droid, OpenWeatherProvider, remove recovery keys).
./add-common-mk-items.sh

# Add the OTA URL to buildinfo.sh.
./add-updater-url

# Put the actual APK's in their proper directories.
./add-f-droid-apk.sh
./add-openweatherprovider-apk.sh

# Remove the googleness of AOSP/Lineage.
./replace-captive-portal-detection-url.sh
./replace-google-dns-servers.sh
./set-default-search-in-jelly.sh

# Force permissive mode for init in LOS 17.1 so recovery works.
./allow-permissive-init.sh
