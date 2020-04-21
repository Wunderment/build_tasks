#!/bin/bash

# This only has to be done for Android 10+ due to AOSP rendering the built in Calendar
# app completly useless.
LOSDIRNAME="lineage-17.1"

cd ~/android/$LOSDIRNAME/packages/apps
mkdir Etar

cp ~/tasks/source/Etar-Android.mk ~/android/$LOSDIRNAME/packages/apps/Etar/Android.mk

# This is a static version at this point, should add some code to find the latest
# version available on F-Droid.
wget https://f-droid.org/repo/ws.xsoh.etar_23.apk
mv ws.xsoh.etar_23.apk Etar.apk
