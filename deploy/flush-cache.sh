#!/bin/bash

# Pull in the user/pass and host name to use for the transfer.
source ~/.WundermentOS/deploy-info.sh

# Go flush the Github cache file on the webserver.
echo "Flushing the OTA updater cache..."
lftp sftp://$WOS_USER:$WOS_PASS@$WOS_HOST -e "set sftp:auto-confirm yes; cd $WOS_DIR_FULL; rm ../../github.cache.json; bye"

echo "Rebuilding the OTA updater cache..."
curl -s https://ota.wunderment.org > /dev/null

# Flush the user/pass and host from the environment.
unset WOS_USER
unset WOS_PASS
unset WOS_HOST
unset WOS_DIR_FULL
unset WOS_GH_REPO
