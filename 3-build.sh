#!/bin/bash

#############################################################
# This builds code into Docker containers ready for deploying
#############################################################

API_TECH='nodejs'

#
# Build the web host
#
./apps/webhost/build.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Build the API
#
./apps/api/build.sh "$API_TECH"
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Indicate success
#
echo 'All application resources were built successfully'