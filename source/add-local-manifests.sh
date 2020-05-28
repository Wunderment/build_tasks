#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
        LOSDIRNAME=$(basename $LOSPATHNAME)

	# Copy over the local manifest files.
	cp ~/tasks/source/F-DroidPrivilegedExtension.xml ~/android/$LOSDIRNAME/.repo/local_manifests
	cp ~/tasks/source/Wunderment-Vendor.xml ~/android/$LOSDIRNAME/.repo/local_manifests

	# Enable the Wunderment vendor config files by adding the "extra" directory to "vendor"
	# and then including Wunderment in to the product.mk file.  Extra is a standard part
	# of the LOS build process and is inherited from "vendor/lineage/config/common.mk.
	mkdir ~/android/$LOSDIRNAME/vendor/extra
	cp ~/tasks/source/extra-product.mk ~/android/$LOSDIRNAME/vendor/extra/product.mk
done

# Seedvault only supports Android 10.
cp ~/tasks/source/Seedvault.xml ~/android/lineage-17.1/.repo/local_manifests
