#!/bin/bash

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	echo "Replacing captive portal detection url for $LOSDIRNAME..."

	# Replace the default captive portal detection URL in the TV app.
	cd $LOSPATHNAME/packages/apps/TV/src/com/android/tv/util

	sed -i 's/clients3.google.com/wunderment.org/' NetworkUtils.java

	# Replace the captive portal detection URL in the setup wizard.
	# Note: For LineageOS 17.1+ this is no longer required as the setup
	# wizard uses the system captive portal URL instead of a hard coded one.
	cd $LOSPATHNAME/packages/apps/SetupWizard/src/org/lineageos/setupwizard

	if [ -f "CaptivePortalSetupActivity.java" ];
	then
		sed -i 's/clients3.google.com/wunderment.org/' CaptivePortalSetupActivity.java
	fi

	# Replace the default captive portal detection in the network monitor.
	cd $LOSPATHNAME/frameworks/base/services/core/java/com/android/server/connectivity

	if [ -f "NetworkMonitor.java" ];
	then
		sed -i 's/connectivitycheck.gstatic.com/wunderment.org/' NetworkMonitor.java
		sed -i 's/www.google.com/wunderment.org/' NetworkMonitor.java
		sed -i 's/gen_204/generate_204/' NetworkMonitor.java
		sed -i 's/play.googleapis.com/wunderment.org/' NetworkMonitor.java
	fi
done
