#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
        LOSDIRNAME=$(basename $LOSPATHNAME)

	# Copy over the local manifest files.
	cp ~/tasks/source/F-DroidPrivilegedExtension.xml ~/android/$LOSDIRNAME/.repo/local_manifests
	cp ~/tasks/source/Wunderment-Vendor.xml ~/android/$LOSDIRNAME/.repo/local_manifests
done

# The Muppets are only needed for LinageOS 17.1 +.
cp ~/tasks/source/TheMuppets.xml ~/android/lineage-17.1/.repo/local_manifests
cp ~/tasks/source/TheMuppets.xml ~/android/lineage-18.0/.repo/local_manifests
