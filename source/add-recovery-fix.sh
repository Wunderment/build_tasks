#!/bin/bash

# In user builds of LOS 17.1 Recoveryi for the OnePlus 6/6t, some additional SEPolicies are needed,
# otherwise during updates it will fail to swap slots at the end of the process.

cd ~/android/lineage-17.1/device/oneplus/sdm845-common/sepolicy/private

# First copy over some files from the qcom device tree.
cp ~/android/lineage-17.1/device/qcom/sepolicy/legacy/vendor/sdm845/hal_bootctl.te .
cp ~/android/lineage-17.1/device/qcom/sepolicy/generic/vendor/common/update_engine_common.te .

# Check to see if we need to patch the script before doing so.
if ! grep "# Recovery fix." genfs_contexts > /dev/null; then
        patch -p < ~/tasks/source/recovery.fix.patch
fi
