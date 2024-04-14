#!/bin/bash

# Print the help screen.
function help_screen {
        echo ""
        if [ -z ${SCRIPT_TITLE+x} ]; then
                echo "Usage: ./build.sh <action> ... <action> <target>"
        else
                echo $SCRIPT_TITLE
        fi

	echo ""
	echo "Supported actions are:"
	echo "    build      - Run WundermentOS build"
	echo "    clean      - Run a make clean"
	echo "    foreground - Run commands in the foreground"
	echo "    log        - Log output"
	echo "    nohup      - Run commands in the background (forces log)"
	echo "    sign       - Run WundermentOS sign"
	echo ""
}

# Common build functions, should be used for virtually all devices.
function common_build_wos {
	echo "Start build process for $DEVICE..."

	# Move in to the build directory
	cd $HOME/android/lineage-$LOS_BUILD_VERSION

	# Setup the build environment
	source build/envsetup.sh
	croot

	# Setup our env variables
	RELEASE_TYPE=RELEASE
	export RELEASE_TYPE

	TARGET_BUILD_VARIANT=user
	export TARGET_BUILD_VARIANT

	TARGET_PRODUCT=lineage_$LOS_DEVICE
	export TARGET_PRODUCT

	# Clean the build environment.
	make installclean

	# Start the build
	echo "Running breakfast for $LOS_DEVICE..."
	breakfast $LOS_DEVICE user

	# Package the files
	echo "Making target packages for $DEVICE..."
	mka target-files-package otatools

	echo "Build process complete for $DEVICE!"
}

# Clean the out directory and other files, minty fresh when done.
function clean_wos {
	echo "Cleaning the build system..."

	# Move in to the build directory
	cd $HOME/android/lineage-$LOS_BUILD_VERSION

	# Setup the build environment
	source build/envsetup.sh
	croot

	make clean
}

# Common signing functions, should be used for none A/B devices.
function sign_wos_target_apks {
	echo "Sign target APK's..."

	# Android 12 (aka Lineage 19.1) changes the intermediates directory path, so let's see which one we have...
	# Assume Android 11 or older to start...
	export WOS_INTERMEDIATES_DIR=$OUT/obj/PACKAGING/target_files_intermediates

	# Now see if we're actually building Android 12...
	if [ -d $OUT/target/product/obj/PACKAGING/target_files_intermediates ]; then
		export WOS_INTERMEDIATES_DIR=$OUT/target/product/obj/PACKAGING/target_files_intermediates
	fi

	# Check to make sure we have files to sign...
	if [ -f $WOS_INTERMEDIATES_DIR/*-target_files*.zip ]; then
		# Sign the apks.
		sign_target_files_apks -o -d $HOME/.android-certs \
		--extra_apks com.android.adbd.apex=$HOME/.android-certs/com.android.adbd \
		--extra_apks com.android.adservices.apex=$HOME/.android-certs/com.android.adservices \
		--extra_apks com.android.adservices.api.apex=$HOME/.android-certs/com.android.adservices.api \
		--extra_apks com.android.appsearch.apex=$HOME/.android-certs/com.android.appsearch \
		--extra_apks com.android.art.apex=$HOME/.android-certs/com.android.art \
		--extra_apks com.android.bluetooth.apex=$HOME/.android-certs/com.android.bluetooth \
		--extra_apks com.android.btservices.apex=$HOME/.android-certs/com.android.btservices \
		--extra_apks com.android.cellbroadcast.apex=$HOME/.android-certs/com.android.cellbroadcast \
		--extra_apks com.android.compos.apex=$HOME/.android-certs/com.android.compos \
		--extra_apks com.android.configinfrastructure.apex=$HOME/.android-certs/com.android.configinfrastructure \
		--extra_apks com.android.connectivity.resources.apex=$HOME/.android-certs/com.android.connectivity.resources \
		--extra_apks com.android.conscrypt.apex=$HOME/.android-certs/com.android.conscrypt \
		--extra_apks com.android.devicelock.apex=$HOME/.android-certs/com.android.devicelock \
		--extra_apks com.android.extservices.apex=$HOME/.android-certs/com.android.extservices \
        --extra_apks com.android.graphics.pdf.apex=$HOME/.android-certs/com.android.graphics.pdf \
        --extra_apks com.android.hardware.biometrics.face.virtual.apex=$HOME/.android-certs/com.android.hardware.biometrics.face.virtual \
        --extra_apks com.android.hardware.biometrics.fingerprint.virtual.apex=$HOME/.android-certs/com.android.hardware.biometrics.fingerprint.virtual \
        --extra_apks com.android.hardware.cas.apex=$HOME/.android-certs/com.android.hardware.cas \
		--extra_apks com.android.hardware.wifi.apex=$HOME/.android-certs/com.android.hardware.wifi \
		--extra_apks com.android.healthfitness.apex=$HOME/.android-certs/com.android.healthfitness \
		--extra_apks com.android.hotspot2.osulogin.apex=$HOME/.android-certs/com.android.hotspot2.osulogin \
		--extra_apks com.android.i18n.apex=$HOME/.android-certs/com.android.i18n \
		--extra_apks com.android.ipsec.apex=$HOME/.android-certs/com.android.ipsec \
		--extra_apks com.android.media.apex=$HOME/.android-certs/com.android.media \
		--extra_apks com.android.media.swcodec.apex=$HOME/.android-certs/com.android.media.swcodec \
		--extra_apks com.android.mediaprovider.apex=$HOME/.android-certs/com.android.mediaprovider \
		--extra_apks com.android.nearby.halfsheet.apex=$HOME/.android-certs/com.android.nearby.halfsheet \
		--extra_apks com.android.networkstack.tethering.apex=$HOME/.android-certs/com.android.networkstack.tethering \
		--extra_apks com.android.neuralnetworks.apex=$HOME/.android-certs/com.android.neuralnetworks \
		--extra_apks com.android.ondevicepersonalization.apex=$HOME/.android-certs/com.android.ondevicepersonalization \
		--extra_apks com.android.os.statsd.apex=$HOME/.android-certs/com.android.os.statsd \
		--extra_apks com.android.permission.apex=$HOME/.android-certs/com.android.permission \
		--extra_apks com.android.resolv.apex=$HOME/.android-certs/com.android.resolv \
		--extra_apks com.android.rkpd.apex=$HOME/.android-certs/com.android.rkpd \
		--extra_apks com.android.runtime.apex=$HOME/.android-certs/com.android.runtime \
		--extra_apks com.android.safetycenter.resources.apex=$HOME/.android-certs/com.android.safetycenter.resources \
		--extra_apks com.android.scheduling.apex=$HOME/.android-certs/com.android.scheduling \
		--extra_apks com.android.sdkext.apex=$HOME/.android-certs/com.android.sdkext \
		--extra_apks com.android.support.apexer.apex=$HOME/.android-certs/com.android.support.apexer \
		--extra_apks com.android.telephony.apex=$HOME/.android-certs/com.android.telephony \
		--extra_apks com.android.telephonymodules.apex=$HOME/.android-certs/com.android.telephonymodules \
		--extra_apks com.android.tethering.apex=$HOME/.android-certs/com.android.tethering \
		--extra_apks com.android.tzdata.apex=$HOME/.android-certs/com.android.tzdata \
		--extra_apks com.android.uwb.apex=$HOME/.android-certs/com.android.uwb \
		--extra_apks com.android.uwb.resources.apex=$HOME/.android-certs/com.android.uwb.resources \
		--extra_apks com.android.virt.apex=$HOME/.android-certs/com.android.virt \
		--extra_apks com.android.vndk.current.apex=$HOME/.android-certs/com.android.vndk.current \
        --extra_apks com.android.vndk.current.on_vendor.apex=$HOME/.android-certs/com.android.vndk.current.on_vendor \
		--extra_apks com.android.wifi.apex=$HOME/.android-certs/com.android.wifi \
		--extra_apks com.android.wifi.dialog.apex=$HOME/.android-certs/com.android.wifi.dialog \
		--extra_apks com.android.wifi.resources.apex=$HOME/.android-certs/com.android.wifi.resources \
        --extra_apks com.google.pixel.camera.hal.apex=$HOME/.android-certs/com.google.pixel.camera.hal \
		--extra_apks com.google.pixel.vibrator.hal.apex=$HOME/.android-certs/com.google.pixel.vibrator.hal \
		--extra_apks com.qorvo.uwb.apex=$HOME/.android-certs/com.qorvo.uwb \
		--extra_apex_payload_key com.android.adbd.apex=$HOME/.android-certs/com.android.adbd.pem \
		--extra_apex_payload_key com.android.adservices.apex=$HOME/.android-certs/com.android.adservices.pem \
		--extra_apex_payload_key com.android.adservices.api.apex=$HOME/.android-certs/com.android.adservices.api.pem \
		--extra_apex_payload_key com.android.appsearch.apex=$HOME/.android-certs/com.android.appsearch.pem \
		--extra_apex_payload_key com.android.art.apex=$HOME/.android-certs/com.android.art.pem \
		--extra_apex_payload_key com.android.bluetooth.apex=$HOME/.android-certs/com.android.bluetooth.pem \
		--extra_apex_payload_key com.android.btservices.apex=$HOME/.android-certs/com.android.btservices.pem \
		--extra_apex_payload_key com.android.cellbroadcast.apex=$HOME/.android-certs/com.android.cellbroadcast.pem \
		--extra_apex_payload_key com.android.compos.apex=$HOME/.android-certs/com.android.compos.pem \
		--extra_apex_payload_key com.android.configinfrastructure.apex=$HOME/.android-certs/com.android.configinfrastructure.pem \
		--extra_apex_payload_key com.android.connectivity.resources.apex=$HOME/.android-certs/com.android.connectivity.resources.pem \
		--extra_apex_payload_key com.android.conscrypt.apex=$HOME/.android-certs/com.android.conscrypt.pem \
		--extra_apex_payload_key com.android.devicelock.apex=$HOME/.android-certs/com.android.devicelock.pem \
		--extra_apex_payload_key com.android.extservices.apex=$HOME/.android-certs/com.android.extservices.pem \
        --extra_apex_payload_key com.android.graphics.pdf.apex=$HOME/.android-certs/com.android.graphics.pdf.pem \
        --extra_apex_payload_key com.android.hardware.biometrics.face.virtual.apex=$HOME/.android-certs/com.android.hardware.biometrics.face.virtual.pem \
        --extra_apex_payload_key com.android.hardware.biometrics.fingerprint.virtual.apex=$HOME/.android-certs/com.android.hardware.biometrics.fingerprint.virtual.pem \
        --extra_apex_payload_key com.android.hardware.cas.apex=$HOME/.android-certs/com.android.hardware.cas.pem \
		--extra_apex_payload_key com.android.hardware.wifi.apex=$HOME/.android-certs/com.android.hardware.wifi.pem \
		--extra_apex_payload_key com.android.healthfitness.apex=$HOME/.android-certs/com.android.healthfitness.pem \
		--extra_apex_payload_key com.android.hotspot2.osulogin.apex=$HOME/.android-certs/com.android.hotspot2.osulogin.pem \
		--extra_apex_payload_key com.android.i18n.apex=$HOME/.android-certs/com.android.i18n.pem \
		--extra_apex_payload_key com.android.ipsec.apex=$HOME/.android-certs/com.android.ipsec.pem \
		--extra_apex_payload_key com.android.media.apex=$HOME/.android-certs/com.android.media.pem \
		--extra_apex_payload_key com.android.media.swcodec.apex=$HOME/.android-certs/com.android.media.swcodec.pem \
		--extra_apex_payload_key com.android.mediaprovider.apex=$HOME/.android-certs/com.android.mediaprovider.pem \
		--extra_apex_payload_key com.android.nearby.halfsheet.apex=$HOME/.android-certs/com.android.nearby.halfsheet.pem \
		--extra_apex_payload_key com.android.networkstack.tethering.apex=$HOME/.android-certs/com.android.networkstack.tethering.pem \
		--extra_apex_payload_key com.android.neuralnetworks.apex=$HOME/.android-certs/com.android.neuralnetworks.pem \
		--extra_apex_payload_key com.android.ondevicepersonalization.apex=$HOME/.android-certs/com.android.ondevicepersonalization.pem \
		--extra_apex_payload_key com.android.os.statsd.apex=$HOME/.android-certs/com.android.os.statsd.pem \
		--extra_apex_payload_key com.android.permission.apex=$HOME/.android-certs/com.android.permission.pem \
		--extra_apex_payload_key com.android.resolv.apex=$HOME/.android-certs/com.android.resolv.pem \
		--extra_apex_payload_key com.android.rkpd.apex=$HOME/.android-certs/com.android.rkpd.pem \
		--extra_apex_payload_key com.android.runtime.apex=$HOME/.android-certs/com.android.runtime.pem \
		--extra_apex_payload_key com.android.safetycenter.resources.apex=$HOME/.android-certs/com.android.safetycenter.resources.pem \
		--extra_apex_payload_key com.android.scheduling.apex=$HOME/.android-certs/com.android.scheduling.pem \
		--extra_apex_payload_key com.android.sdkext.apex=$HOME/.android-certs/com.android.sdkext.pem \
		--extra_apex_payload_key com.android.support.apexer.apex=$HOME/.android-certs/com.android.support.apexer.pem \
		--extra_apex_payload_key com.android.telephony.apex=$HOME/.android-certs/com.android.telephony.pem \
		--extra_apex_payload_key com.android.telephonymodules.apex=$HOME/.android-certs/com.android.telephonymodules.pem \
		--extra_apex_payload_key com.android.tethering.apex=$HOME/.android-certs/com.android.tethering.pem \
		--extra_apex_payload_key com.android.tzdata.apex=$HOME/.android-certs/com.android.tzdata.pem \
		--extra_apex_payload_key com.android.uwb.apex=$HOME/.android-certs/com.android.uwb.pem \
		--extra_apex_payload_key com.android.uwb.resources.apex=$HOME/.android-certs/com.android.uwb.resources.pem \
		--extra_apex_payload_key com.android.virt.apex=$HOME/.android-certs/com.android.virt.pem \
		--extra_apex_payload_key com.android.vndk.current.apex=$HOME/.android-certs/com.android.vndk.current.pem \
		$WOS_INTERMEDIATES_DIR/*-target_files*.zip \
		signed-target_files.zip

	else
		echo "    ...error no intermediate files found!"
	fi
}

# Common signing functions, should be used for A/B devices with a prebuilt vendor.img, which
# is the case for most LineageOS 17.1 devices.
function sign_wos_target_apks_vendor_prebuilt {
	echo "Sign target APK's with prebuilt vendor partitions..."

	# Android 12 (aka Lineage 19.1) changes the intermediates directory path, so let's see which one we have...
	# Assume Android 11 or older to start...
	export WOS_INTERMEDIATES_DIR=$OUT/obj/PACKAGING/target_files_intermediates

	# Now see if we're actually building Android 12...
	if [ -d $OUT/target/product/obj/PACKAGING/target_files_intermediates ]; then
		export WOS_INTERMEDIATES_DIR=$OUT/target/product/obj/PACKAGING/target_files_intermediates
	fi

	# Make sure our vendor image directory exists.
	if [ ! -d $HOME/android/lineage-$LOS_BUILD_VERSION/device/$VENDOR/$LOS_DEVICE/images/vendor ]; then
		mkdir -p $HOME/android/lineage-$LOS_BUILD_VERSION/device/$VENDOR/$LOS_DEVICE/images/vendor
	fi

	# Get the signed vendor.img from the out directory.
	cp $WOS_INTERMEDIATES_DIR/lineage_$LOS_DEVICE-target_files-eng.WundermentOS/IMAGES/vendor.img $HOME/android/lineage-$LOS_BUILD_VERSION/device/$VENDOR/$LOS_DEVICE/images/vendor

	# Check to make sure we have files to sign...
	if [ -f $WOS_INTERMEDIATES_DIR/*-target_files*.zip ]; then
		# Sign the apks.
		sign_target_files_apks -o -d $HOME/.android-certs \
		--extra_apks com.android.adbd.apex=$HOME/.android-certs/com.android.adbd \
		--extra_apks com.android.adservices.apex=$HOME/.android-certs/com.android.adservices \
		--extra_apks com.android.adservices.api.apex=$HOME/.android-certs/com.android.adservices.api \
		--extra_apks com.android.appsearch.apex=$HOME/.android-certs/com.android.appsearch \
		--extra_apks com.android.art.apex=$HOME/.android-certs/com.android.art \
		--extra_apks com.android.bluetooth.apex=$HOME/.android-certs/com.android.bluetooth \
		--extra_apks com.android.btservices.apex=$HOME/.android-certs/com.android.btservices \
		--extra_apks com.android.cellbroadcast.apex=$HOME/.android-certs/com.android.cellbroadcast \
		--extra_apks com.android.compos.apex=$HOME/.android-certs/com.android.compos \
		--extra_apks com.android.configinfrastructure.apex=$HOME/.android-certs/com.android.configinfrastructure \
		--extra_apks com.android.connectivity.resources.apex=$HOME/.android-certs/com.android.connectivity.resources \
		--extra_apks com.android.conscrypt.apex=$HOME/.android-certs/com.android.conscrypt \
		--extra_apks com.android.devicelock.apex=$HOME/.android-certs/com.android.devicelock \
		--extra_apks com.android.extservices.apex=$HOME/.android-certs/com.android.extservices \
		--extra_apks com.android.hardware.wifi.apex=$HOME/.android-certs/com.android.hardware.wifi \
		--extra_apks com.android.healthfitness.apex=$HOME/.android-certs/com.android.healthfitness \
		--extra_apks com.android.hotspot2.osulogin.apex=$HOME/.android-certs/com.android.hotspot2.osulogin \
		--extra_apks com.android.i18n.apex=$HOME/.android-certs/com.android.i18n \
		--extra_apks com.android.ipsec.apex=$HOME/.android-certs/com.android.ipsec \
		--extra_apks com.android.media.apex=$HOME/.android-certs/com.android.media \
		--extra_apks com.android.media.swcodec.apex=$HOME/.android-certs/com.android.media.swcodec \
		--extra_apks com.android.mediaprovider.apex=$HOME/.android-certs/com.android.mediaprovider \
		--extra_apks com.android.nearby.halfsheet.apex=$HOME/.android-certs/com.android.nearby.halfsheet \
		--extra_apks com.android.networkstack.tethering.apex=$HOME/.android-certs/com.android.networkstack.tethering \
		--extra_apks com.android.neuralnetworks.apex=$HOME/.android-certs/com.android.neuralnetworks \
		--extra_apks com.android.ondevicepersonalization.apex=$HOME/.android-certs/com.android.ondevicepersonalization \
		--extra_apks com.android.os.statsd.apex=$HOME/.android-certs/com.android.os.statsd \
		--extra_apks com.android.permission.apex=$HOME/.android-certs/com.android.permission \
		--extra_apks com.android.resolv.apex=$HOME/.android-certs/com.android.resolv \
		--extra_apks com.android.rkpd.apex=$HOME/.android-certs/com.android.rkpd \
		--extra_apks com.android.runtime.apex=$HOME/.android-certs/com.android.runtime \
		--extra_apks com.android.safetycenter.resources.apex=$HOME/.android-certs/com.android.safetycenter.resources \
		--extra_apks com.android.scheduling.apex=$HOME/.android-certs/com.android.scheduling \
		--extra_apks com.android.sdkext.apex=$HOME/.android-certs/com.android.sdkext \
		--extra_apks com.android.support.apexer.apex=$HOME/.android-certs/com.android.support.apexer \
		--extra_apks com.android.telephony.apex=$HOME/.android-certs/com.android.telephony \
		--extra_apks com.android.telephonymodules.apex=$HOME/.android-certs/com.android.telephonymodules \
		--extra_apks com.android.tethering.apex=$HOME/.android-certs/com.android.tethering \
		--extra_apks com.android.tzdata.apex=$HOME/.android-certs/com.android.tzdata \
		--extra_apks com.android.uwb.apex=$HOME/.android-certs/com.android.uwb \
		--extra_apks com.android.uwb.resources.apex=$HOME/.android-certs/com.android.uwb.resources \
		--extra_apks com.android.virt.apex=$HOME/.android-certs/com.android.virt \
		--extra_apks com.android.vndk.current.apex=$HOME/.android-certs/com.android.vndk.current \
		--extra_apks com.android.wifi.apex=$HOME/.android-certs/com.android.wifi \
		--extra_apks com.android.wifi.dialog.apex=$HOME/.android-certs/com.android.wifi.dialog \
		--extra_apks com.android.wifi.resources.apex=$HOME/.android-certs/com.android.wifi.resources \
		--extra_apks com.google.pixel.vibrator.hal.apex=$HOME/.android-certs/com.google.pixel.vibrator.hal \
		--extra_apks com.qorvo.uwb.apex=$HOME/.android-certs/com.qorvo.uwb \
		--extra_apex_payload_key com.android.adbd.apex=$HOME/.android-certs/com.android.adbd.pem \
		--extra_apex_payload_key com.android.adservices.apex=$HOME/.android-certs/com.android.adservices.pem \
		--extra_apex_payload_key com.android.adservices.api.apex=$HOME/.android-certs/com.android.adservices.api.pem \
		--extra_apex_payload_key com.android.appsearch.apex=$HOME/.android-certs/com.android.appsearch.pem \
		--extra_apex_payload_key com.android.art.apex=$HOME/.android-certs/com.android.art.pem \
		--extra_apex_payload_key com.android.bluetooth.apex=$HOME/.android-certs/com.android.bluetooth.pem \
		--extra_apex_payload_key com.android.btservices.apex=$HOME/.android-certs/com.android.btservices.pem \
		--extra_apex_payload_key com.android.cellbroadcast.apex=$HOME/.android-certs/com.android.cellbroadcast.pem \
		--extra_apex_payload_key com.android.compos.apex=$HOME/.android-certs/com.android.compos.pem \
		--extra_apex_payload_key com.android.configinfrastructure.apex=$HOME/.android-certs/com.android.configinfrastructure.pem \
		--extra_apex_payload_key com.android.connectivity.resources.apex=$HOME/.android-certs/com.android.connectivity.resources.pem \
		--extra_apex_payload_key com.android.conscrypt.apex=$HOME/.android-certs/com.android.conscrypt.pem \
		--extra_apex_payload_key com.android.devicelock.apex=$HOME/.android-certs/com.android.devicelock.pem \
		--extra_apex_payload_key com.android.extservices.apex=$HOME/.android-certs/com.android.extservices.pem \
		--extra_apex_payload_key com.android.hardware.wifi.apex=$HOME/.android-certs/com.android.hardware.wifi.pem \
		--extra_apex_payload_key com.android.healthfitness.apex=$HOME/.android-certs/com.android.healthfitness.pem \
		--extra_apex_payload_key com.android.hotspot2.osulogin.apex=$HOME/.android-certs/com.android.hotspot2.osulogin.pem \
		--extra_apex_payload_key com.android.i18n.apex=$HOME/.android-certs/com.android.i18n.pem \
		--extra_apex_payload_key com.android.ipsec.apex=$HOME/.android-certs/com.android.ipsec.pem \
		--extra_apex_payload_key com.android.media.apex=$HOME/.android-certs/com.android.media.pem \
		--extra_apex_payload_key com.android.media.swcodec.apex=$HOME/.android-certs/com.android.media.swcodec.pem \
		--extra_apex_payload_key com.android.mediaprovider.apex=$HOME/.android-certs/com.android.mediaprovider.pem \
		--extra_apex_payload_key com.android.nearby.halfsheet.apex=$HOME/.android-certs/com.android.nearby.halfsheet.pem \
		--extra_apex_payload_key com.android.networkstack.tethering.apex=$HOME/.android-certs/com.android.networkstack.tethering.pem \
		--extra_apex_payload_key com.android.neuralnetworks.apex=$HOME/.android-certs/com.android.neuralnetworks.pem \
		--extra_apex_payload_key com.android.ondevicepersonalization.apex=$HOME/.android-certs/com.android.ondevicepersonalization.pem \
		--extra_apex_payload_key com.android.os.statsd.apex=$HOME/.android-certs/com.android.os.statsd.pem \
		--extra_apex_payload_key com.android.permission.apex=$HOME/.android-certs/com.android.permission.pem \
		--extra_apex_payload_key com.android.resolv.apex=$HOME/.android-certs/com.android.resolv.pem \
		--extra_apex_payload_key com.android.rkpd.apex=$HOME/.android-certs/com.android.rkpd.pem \
		--extra_apex_payload_key com.android.runtime.apex=$HOME/.android-certs/com.android.runtime.pem \
		--extra_apex_payload_key com.android.safetycenter.resources.apex=$HOME/.android-certs/com.android.safetycenter.resources.pem \
		--extra_apex_payload_key com.android.scheduling.apex=$HOME/.android-certs/com.android.scheduling.pem \
		--extra_apex_payload_key com.android.sdkext.apex=$HOME/.android-certs/com.android.sdkext.pem \
		--extra_apex_payload_key com.android.support.apexer.apex=$HOME/.android-certs/com.android.support.apexer.pem \
		--extra_apex_payload_key com.android.telephony.apex=$HOME/.android-certs/com.android.telephony.pem \
		--extra_apex_payload_key com.android.telephonymodules.apex=$HOME/.android-certs/com.android.telephonymodules.pem \
		--extra_apex_payload_key com.android.tethering.apex=$HOME/.android-certs/com.android.tethering.pem \
		--extra_apex_payload_key com.android.tzdata.apex=$HOME/.android-certs/com.android.tzdata.pem \
		--extra_apex_payload_key com.android.uwb.apex=$HOME/.android-certs/com.android.uwb.pem \
		--extra_apex_payload_key com.android.uwb.resources.apex=$HOME/.android-certs/com.android.uwb.resources.pem \
		--extra_apex_payload_key com.android.virt.apex=$HOME/.android-certs/com.android.virt.pem \
		--extra_apex_payload_key com.android.vndk.current.apex=$HOME/.android-certs/com.android.vndk.current.pem \
		--extra_apex_payload_key com.android.wifi.apex=$HOME/.android-certs/com.android.wifi.pem \
		--extra_apex_payload_key com.android.wifi.dialog.apex=$HOME/.android-certs/com.android.wifi.dialog.pem \
		--extra_apex_payload_key com.android.wifi.resources.apex=$HOME/.android-certs/com.android.wifi.resources.pem \
		--extra_apex_payload_key com.google.pixel.vibrator.hal.apex=$HOME/.android-certs/com.google.pixel.vibrator.hal.pem \
		--extra_apex_payload_key com.qorvo.uwb.apex=$HOME/.android-certs/com.qorvo.uwb.pem \
		--prebuilts_path $HOME/android/lineage-$LOS_BUILD_VERSION/device/$VENDOR/$LOS_DEVICE/images/vendor \
		$WOS_INTERMEDIATES_DIR/*-target_files-*.zip \
		signed-target_files.zip
	else
		echo "    ...error no intermediate files found!"
	fi
}

# Common OTA generation functions, should be used for virtually all devices.
function sign_wos_target_files {
	# Make sure the release directory exists.
	if [ ! -d $HOME/releases/ota/$LOS_DEVICE/ ]; then
		mkdir $HOME/releases/ota/$LOS_DEVICE/
	fi

	# Create the release file
	echo "Create release file: $PKGNAME..."

	if [ -f signed-target_files.zip ]; then
		ota_from_target_files -k $HOME/.android-certs/releasekey --block signed-target_files.zip $HOME/releases/ota/$LOS_DEVICE/$PKGNAME.zip
	else
		echo "    ...error signed-target_files.zip not found!"
	fi
}

# Super function to sign and generate the OTA, should only be used for non-A/B devices.
function sign_wos_target_package {
	sign_wos_target_apks
	sign_wos_target_files
}

# Common checksum and buildprop generation function, basically the cleanup once everything else is done.
function checksum_buildprop_cleanup {
	# Make sure the release directory exists.
	if [ ! -d $HOME/releases/ota/$LOS_DEVICE/ ]; then
		mkdir $HOME/releases/ota/$LOS_DEVICE/
	fi

	# Make sure the signed_files directory exists.
	if [ ! -d $HOME/releases/signed_files/$LOS_DEVICE/ ]; then
		mkdir $HOME/releases/signed_files/$LOS_DEVICE/
	fi

	# Make sure the release file exists.
	if [ -f $HOME/releases/ota/$LOS_DEVICE/$PKGNAME.zip ]; then
	    # Create the md5 checksum file for the release.
	    echo "Create the md5 checksum..."
	    # Move in to the OTA directory so md5sum doesn't add the full path to the filename during output.
	    pushd $PWD
	    cd $HOME/releases/ota/$LOS_DEVICE
	    md5sum $PKGNAME.zip > $PKGNAME.zip.md5sum
	    popd

	    # Grab a copy of the build.prop file.
	    echo "Extract the build.prop file..."
	    unzip -j signed-target_files.zip SYSTEM/build.prop
	    mv build.prop $HOME/releases/ota/$LOS_DEVICE/$PKGNAME.zip.prop
	    touch -r $HOME/releases/ota/$LOS_DEVICE/$PKGNAME.zip.md5sum $HOME/releases/ota/$LOS_DEVICE/$PKGNAME.zip.prop

	    # Cleanup the signed target files zip.
	    echo "Store signed target files for future incremental updates..."
	    mv signed-target_files.zip $HOME/releases/signed_files/$LOS_DEVICE/signed-target_files-$LOS_DEVICE-$TODAY.zip

	    # Grab a copy of the current recovery file from the signed target files.
	    echo "Building recovery zip..."

	    # Grab the payload file to extract the img files from.
	    echo -n "Checking for payload.bin..."
	    unzip -o -j $HOME/releases/ota/$LOS_DEVICE/$PKGNAME.zip payload.bin -d $HOME/releases/ota/$LOS_DEVICE > /dev/null 2>&1

	    # Check to see if the payload.bin file was extracted successfully.  If not, this device doesn't use A/B style packaging.
	    if [ -f $HOME/releases/ota/$LOS_DEVICE/payload.bin ]; then
	    	echo "found."

		    # If the device hasn't defined a specific file to use as recovery, try and detect it.
		    if [ "$LOS_RECOVERY_IMG" == "" ]; then
			    # Start by assuming there is a real recovery partition, if not, we'll use the boot.img instead.
			    $HOME/bin/payload-dumper-go -o $HOME/releases/ota/$LOS_DEVICE -partitions recovery $HOME/releases/ota/$LOS_DEVICE/payload.bin > /dev/null 2>&1
			   	RECOVERYFILE="$HOME/releases/ota/$LOS_DEVICE/recovery"
			    if [ ! -f $RECOVERYFILE.img ]; then
				   	echo "Using boot as recovery."
				    $HOME/bin/payload-dumper-go -o $HOME/releases/ota/$LOS_DEVICE -partitions boot $HOME/releases/ota/$LOS_DEVICE/payload.bin > /dev/null 2>&1
				   	RECOVERYFILE="$HOME/releases/ota/$LOS_DEVICE/boot"
				else
					echo "Using recovery as recovery."
			    fi

			   	# If we need any additional partitions for the recovery, extract them now.
			   	if [ "$LOS_ADDITIONAL_RECOVERY_IMGS" != "" ]; then
				   	echo "Extracting additional partitions: $LOS_ADDITIONAL_RECOVERY_IMGS..."
			    	for $ADDFILE in $LOS_ADDITIONAL_RECOVERY_IMGS; do
				   		$HOME/bin/payload-dumper-go -o $HOME/releases/ota/$LOS_DEVICE -partitions $ADDFILE $HOME/releases/ota/$LOS_DEVICE/payload.bin > /dev/null 2>&1
				   	done
			   	fi
			else
			    # Use the passed in recovery name.
				echo "Using $LOS_RECOVERY_IMG as recovery."
			    $HOME/bin/payload-dumper-go -o $HOME/releases/ota/$LOS_DEVICE -partitions $LOS_RECOVERY_IMG $HOME/releases/ota/$LOS_DEVICE/payload.bin #> /dev/null 2>&1
			   	RECOVERYFILE="$HOME/releases/ota/$LOS_DEVICE/$LOS_RECOVERY_IMG"

			   	# If we need any additional partitions for the recovery, extract them now.
			   	if [ "$LOS_ADDITIONAL_RECOVERY_IMGS" != "" ]; then
				   	echo "Extracting additional partitions: $LOS_ADDITIONAL_RECOVERY_IMGS..."
			    	for $ADDFILE in $LOS_ADDITIONAL_RECOVERY_IMGS; do
				   		$HOME/bin/payload-dumper-go -o $HOME/releases/ota/$LOS_DEVICE -partitions $ADDFILE $HOME/releases/ota/$LOS_DEVICE/payload.bin > /dev/null 2>&1
				   	done
			   	fi
			fi

		   	# Delete the payload bin as we no longer need it.
		   	rm $HOME/releases/ota/$LOS_DEVICE/payload.bin
		else
	    	echo "not found."

			if [ "$LOS_RECOVERY_IMG" == "" ]; then
				LOS_RECOVERY_IMG="recovery"
			fi

	    	echo "Unzipping raw $LOS_RECOVERY_IMG partition..."

		    unzip -o -j $HOME/releases/ota/$LOS_DEVICE/$PKGNAME.zip $LOS_RECOVERY_IMG.img -d $HOME/releases/ota/$LOS_DEVICE > /dev/null 2>&1

		    RECOVERYFILE="$HOME/releases/ota/$LOS_DEVICE/$LOS_RECOVERY_IMG"
		fi

	    # Build the new recovery filename for the release.
		RECOVERYNAME="$HOME/releases/ota/$LOS_DEVICE/WundermentOS-$LOS_BUILD_VERSION-$TODAY-recovery-$LOS_DEVICE"

		# Move and zip the recovery image to the proper release directory.
		mv $RECOVERYFILE.img $RECOVERYNAME.img
		zip -j $RECOVERYNAME.zip $RECOVERYNAME.img
		rm $RECOVERYNAME.img

		# Some devices need additional image files added to the recovery zip, do that now if required.
	    if [ "$LOS_ADDITIONAL_RECOVERY_IMGS" != "" ]; then
	    	for $ADDFILE in $LOS_ADDITIONAL_RECOVERY_IMGS; do
	    		if [ -f "$ADDFILE.img" ]; then
	    			zip -j $RECOVERYNAME.zip $HOME/releases/ota/$LOS_DEVICE/$ADDFILE.img
	    			rm $HOME/releases/ota/$LOS_DEVICE/$ADDFILE.img
	    		fi
	    	done
	    fi

	    # Now add the appropriate pkmd.bin file to the recovery zip for user convenience.
		zip -j $RECOVERYNAME.zip $HOME/.android-certs/Wunderment-pkmd*.bin

		# Remove older builds.
		OTADIR="$HOME/releases/ota/$LOS_DEVICE"

		# Be extra paranoid and make sure the directory exists before call find to delete files.
		if [ -d $OTADIR ]; then
			find $OTADIR -depth -maxdepth 1 -mtime +45 -type f -delete
		fi

		# Remove older signed files.
		SFDIR="$HOME/releases/signed_files/$LOS_DEVICE"

		# Be extra paranoid and make sure the directory exists before call find to delete files.
		if [ -d $SFDIR ]; then
			find $SFDIR -depth -maxdepth 1 -mtime +45 -type f -delete
		fi
	else
		echo "ERROR: Release file ($HOME/releases/ota/$LOS_DEVICE/$PKGNAME.zip) not found!"
	fi
}

# E-mail out the build/sign log.
function send_build_sign_log {
	WOS_LOG_TEMP=$(mktemp)
	WOS_LOG_FILE=$OUTDEV
	WOS_LOG_ZIP=$OUTDEV.zip

	head $WOS_LOG_FILE > $WOS_LOG_TEMP
	echo " " >> $WOS_LOG_TEMP
	echo "." >> $WOS_LOG_TEMP
	echo "." >> $WOS_LOG_TEMP
	echo "." >> $WOS_LOG_TEMP
	echo " " >> $WOS_LOG_TEMP
	tail $WOS_LOG_FILE >> $WOS_LOG_TEMP

	# Zip the log file because it can be very large, but junk the path.
	zip -j $WOS_LOG_ZIP $WOS_LOG_FILE > /dev/null 2>&1

	cat $WOS_LOG_TEMP | mutt -s "WundermentOS Build Log for $DEVICE" $WOS_LOGDEST -a $WOS_LOG_ZIP

	rm $WOS_LOG_TEMP
	rm $WOS_LOG_ZIP
}

# Validate the release file size.
function validate_release_size {
	echo -n "Validating release size... " >> $OUTDEV	# Get the file names for the last two releases.

	# Make sure the release file exists.
	if [ -f $HOME/releases/ota/$LOS_DEVICE/$PKGNAME.zip ]; then
		NEWFILE=$(ls -t $HOME/releases/ota/$LOS_DEVICE/$PKGNAME.zip | head -n 1)
		OLDFILE=$(ls -t $HOME/releases/ota/$LOS_DEVICE/WundermentOS-*-release-*-signed.zip | head -n 2 | tail -n 1)

		# Now get their file sizes.
		if [ "$NEWFILE" = "" ]; then
			NEWSIZE=0
		else
			NEWSIZE=$(stat -c%s $NEWFILE)
		fi

		if [ "$OLDFILE" = "" ]; then
			OLDSIZE=0
		else
			OLDSIZE=$(stat -c%s $OLDFILE)
		fi

		# Make it look pretty for display later.
		FNEWSIZE=$(printf "%'d" $NEWSIZE)
		FOLDSIZE=$(printf "%'d" $OLDSIZE)

		# If one of the filesize is 0, then we shouldn't bother checking as one of them doesn't exist.
		if [ $NEWSIZE -gt 0 ] && [ $OLDSIZE -gt 0 ]; then
			# Make sure we don't calculate a negative percentage.
			if [ $NEWSIZE -lt $OLDSIZE ]; then
				PERCENT=$(bc <<< "scale=0; ($OLDSIZE - $NEWSIZE)/$NEWSIZE")
			else
				PERCENT=$(bc <<< "scale=0; ($NEWSIZE - $OLDSIZE)/$OLDSIZE")
			fi

			# Now let's make sure we haven't varied from the last build by too much.
			if [ $PERCENT -gt 0 ]; then
				if [ $DOLOG == "true" ]; then
					echo $'New release size: '"$FNEWSIZE"$'\nOld release size: '"$FOLDSIZE"$'\nPercentage change: '"$PERCENT"$'%\nDevice: '"$DEVICE" | mail -s "WundermentOS release size change is too large for $DEVICE!" $WOS_LOGDEST
				fi

				echo $'[WARNING] Percentage change since last signing is too large!\nNew release size: '"$FNEWSIZE"$'\nOld release size: '"$FOLDSIZE"$'\nPercentage change: '"$PERCENT"$'%\nDevice: '"$DEVICE" >> $OUTDEV
			else
				echo " new file size is $FNEWSIZE bytes... done." >> $OUTDEV
			fi
		else
			echo "skipping, only one file to compare." >> $OUTDEV
		fi
	else
		echo "ERROR: Release file ($HOME/releases/ota/$LOS_DEVICE/$PKGNAME.zip) not found!"
	fi
}