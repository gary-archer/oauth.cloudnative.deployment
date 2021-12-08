#!/bin/bash

#############################################################
# This builds code into Docker containers ready for deploying
#############################################################

API_TECH='netcore'

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Build the web host
#
./webhostdeploy/build.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Build the API
#
./finalapideploy/build.sh "$API_TECH"
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Build the token handler
#
./tokenhandlerdeploy/build.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Download the OAuth proxy plugin to run in the reverse proxy
#
rm -rf oauth-proxy-plugin
git clone https://github.com/curityio/kong-bff-plugin oauth-proxy-plugin
if [ $? -ne 0 ]; then
  echo '*** Kong cookie decryption plugin download problem encountered'
  exit 1
fi
cd roauth-proxy-plugin
git checkout feature/nginx-lua-oauth-proxy-plugin

#
# Indicate success
#
echo 'All application resources were built successfully'