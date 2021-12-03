#!/bin/bash

############################################################
# This deploys Docker containers into the Kubernetes cluster
############################################################

API_TECH='nodejs'

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
# Deploy the reverse proxy
#
./reverse-proxy/deploy.sh

#
# Indicate success
#
echo 'All application resources were deployed successfully'
