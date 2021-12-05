#!/bin/bash

#############################################################
# This builds code into Docker containers ready for deploying
#############################################################

API_TECH='nodejs'

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"
rm -rf resources
mkdir resources

#
# Build the web host
#
./webhost/build.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Build the API
#
./api/build.sh "$API_TECH"
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Build the token handler
#
./tokenhandler/build.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Download the cookie decryption reverse proxy plugin
#
git clone https://github.com/curityio/kong-bff-plugin resources/kong-bff-plugin
if [ $? -ne 0 ]; then
  echo '*** Kong cookie decryption plugin download problem encountered'
  exit 1
fi

#
# Indicate success
#
echo 'All application resources were built successfully'