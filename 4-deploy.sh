#!/bin/bash

############################################################
# This deploys Docker containers into the Kubernetes cluster
############################################################

API_TECH='netcore'

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Deploy the web host
#
./webhost/deploy.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy the API
#
./api/deploy.sh "$API_TECH"
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy the token handler
#
./tokenhandler/deploy.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy the reverse proxy
#
./reverseproxy/deploy.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Indicate success
#
echo 'All application resources were deployed successfully'
