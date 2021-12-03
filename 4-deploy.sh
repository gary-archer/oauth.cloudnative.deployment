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
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Close down the registry for Docker images now that we've finished with it
#
#docker container stop registry 1>/dev/null
#docker container rm -v registry 1>/dev/null

#
# Indicate success
#
echo 'All application resources were deployed successfully'
