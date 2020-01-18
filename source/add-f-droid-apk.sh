#!/bin/bash

cd ~/android/lineage/packages/apps
mkdir F-Droid

cp ~/tasks/source/F-Droid-Android.mk ~/android/lineage/packages/apps/F-Droid/Android.mk

wget https://f-droid.org/FDroid.apk
