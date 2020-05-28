#!/bin/bash

cd ~/tasks/source

# Add the new local manifests to repo.
./add-local-manifests.sh

# Added the vendor/extra directory and files.
./add-vendor-extra.sh

# Remove the lineage build keys.
./remove-lineage-keys.sh

# Add the OTA URL to buildinfo.sh.
./add-updater-url

# Put the actual APK's in their proper directories.
./add-f-droid-apk.sh
./add-openweatherprovider-apk.sh

# Remove the googleness of AOSP/Lineage.
./replace-captive-portal-detection-url.sh
./replace-google-dns-servers.sh
./set-default-search-in-jelly.sh
