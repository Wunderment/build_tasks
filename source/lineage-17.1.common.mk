
# Add F-Droid and it's privilege extension.
PRODUCT_PACKAGES += \
    F-DroidPrivilegedExtension \
    F-Droid

# Add Seedvault.
PRODUCT_PACKAGES += \
    Seedvault \
    BasicDreams

# Remove the lineage signing keys from the recovery build, we only want ours here which get autoamtically
# added during the signing process.
PRODUCT_EXTRA_RECOVERY_KEYS := 

