#!/bin/bash

# Note: Recovery for LOS 17.1 currently needs permissive mode set for init.

cd ~/android/lineage-17.1/system/core/init

sed -i 's/"-DUSER_MODE_LINUX"],/\n                "-DUSER_MODE_LINUX",\n                "-UALLOW_PERMISSIVE_SELINUX",\n                "-DALLOW_PERMISSIVE_SELINUX=1",\n            ],/' Android.bp
