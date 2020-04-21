#!/bin/bash

# Note: Android 10 castrates the Calendar app to the point of uselessness, no ability to add or edit events.
#	As such, we've already included Etar (https://github.com/Etar-Group/Etar-Calendar) from F-Droid as
#       a replacement so we can just remove the Calendar app from the build.

cd ~/android/lineage-17.1/build/target/product

sed -i '/Calendar/d' handheld_product.mk
sed -i '/Calendar/d' mainline_arm64.mk

