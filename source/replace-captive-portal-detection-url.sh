#!/bin/bash

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
        LOSDIRNAME=$(basename $LOSPATHNAME)

	# Replace the default captive portal detection URL in the TV app.
	cd ~/android/$LOSDIRNAME/packages/apps/TV/src/com/android/tv/util

	sed 's/clients3.google.com/wunderment.org/' NetworkUtils.java > NetworkUtils.java.new 

	rm NetworkUtils.java
	mv NetworkUtils.java.new NetworkUtils.java

	# Replace the captive portal detection URL in the setup wizard.
	cd ~/android/$LOSDIRNAME/packages/apps/SetupWizard/src/org/lineageos/setupwizard

	sed 's/clients3.google.com/wunderment.org/' CaptivePortalSetupActivity.java > CaptivePortalSetupActivity.java.new 

	rm CaptivePortalSetupActivity.java
	mv CaptivePortalSetupActivity.java.new CaptivePortalSetupActivity.java

	# Replace the default captive portal deteciton in the network monitor.
	cd ~/android/$LOSDIRNAME/frameworks/base/services/core/java/com/android/server/connectivity

	if [ -f "NetworkMonitor.java" ];
	then
		sed 's/connectivitycheck.gstatic.com/wunderment.org/' NetworkMonitor.java > NetworkMonitor.java.new 
		sed 's/www.google.com/wunderment.org/' NetworkMonitor.java.new > NetworkMonitor.java 
		sed 's/gen_204/generate_204/' NetworkMonitor.java > NetworkMonitor.java.new 
		sed 's/play.googleapis.com/wunderment.org/' NetworkMonitor.java.new > NetworkMonitor.java 

		rm NetworkMonitor.java.new
	fi
done
