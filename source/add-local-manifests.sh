#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
        LOSDIRNAME=$(basename $LOSPATHNAME)

	# Copy over the local manifest files.
	cp ~/tasks/source/F-DroidPrivilegedExtension.xml ~/android/$LOSDIRNAME/.repo/local_manifests
	cp ~/tasks/source/Wunderment-Vendor.xml ~/android/$LOSDIRNAME/.repo/local_manifests
done

# Seedvault only supports Android 10.
cp ~/tasks/source/Seedvault.xml ~/android/lineage-17.1/.repo/local_manifests
