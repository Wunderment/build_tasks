#!/bin/bash

cd ~/tasks/source

# Add the new local manifests to repo.
./add-local-manifests.sh

# Add the custom signing script for prebuilt vendor images.
./add-sign-prebuilt.sh

# Add the Wunderment update server to the build.
./add-updater-url

# Can the updater to allow cross major version upgrades (aka from 17.1 to 18.1).
./add-updater-canInstall.sh

# Added the vendor/extra directory and files.
./add-vendor-extra.sh

# Remove the lineage build keys.
./remove-lineage-keys.sh

# Put the actual APK's in their proper directories.
./add-f-droid-apk.sh
./add-openweatherprovider-apk.sh

# Remove the googleness of AOSP/Lineage.
./replace-captive-portal-detection-url.sh
./replace-google-dns-servers.sh
./replace-google-ntp-servers.sh
./set-default-search-in-jelly.sh
