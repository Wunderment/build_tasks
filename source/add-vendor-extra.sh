#!/bin/bash

cd ~/tasks/source

# Update for all versions of LOS that we have.
for LOSPATHNAME in ~/android/lineage-*; do
	LOSDIRNAME=$(basename $LOSPATHNAME)

	# Enable the Wunderment vendor config files by adding the "extra" directory to "vendor"
	# and then including Wunderment in to the product.mk file.  Extra is a standard part
	# of the LOS build process and is inherited from "vendor/lineage/config/common.mk.
	if [[ ! -d $LOSPATHNAME/vendor/extra ]]; then
		mkdir $LOSPATHNAME/vendor/extra
	fi

	if [[ ! -f ~/android/$LOSDIRNAME/vendor/extra/product.mk ]]; then
		echo -n "Adding product.mk to vendor/extra for $LOSPATHNAME..."
		cp ~/tasks/source/extra-product.mk $LOSPATHNAME/vendor/extra/product.mk
		echo "done."
	fi
done
