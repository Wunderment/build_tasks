#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
        LOSDIRNAME=$(basename $LOSPATHNAME)

	# Remove the lineageos build keys from the signing process
	sed -i 's/PRODUCT_EXTRA_RECOVERY_KEYS += \\/PRODUCT_EXTRA_RECOVERY_KEYS :=/' ~/android/$LOSDIRNAME/vendor/lineage/config/common.mk
	sed -i 's/    vendor\/lineage\/build\/target\/product\/security\/lineage//' ~/android/$LOSDIRNAME/vendor/lineage/config/common.mk
done
