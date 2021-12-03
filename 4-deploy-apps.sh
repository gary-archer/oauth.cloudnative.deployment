#!/bin/bash

############################################################
# This deploys Docker containers into the Kubernetes cluster
############################################################

API_TECH='java'

#
# Deploy the API
#
./apps/api/deploy.sh "$API_TECH"
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy the web host
#
#./apps/webhost/deploy.sh
#if [ $? -ne 0 ]; then
#  exit 1
#fi

#
# Indicate success
#
echo 'All application resources were deployed successfully'
