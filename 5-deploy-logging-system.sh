#!/bin/bash

###################################################################
# This deploys Elastic Stack containers into the Kubernetes cluster
###################################################################

API_TECH='netcore'

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Deploy Elasticsearch resources
#
./elasticstack/elasticsearch/deploy.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# See if I can connect via kubectl and curl
#
POD=
kube

#
# Indicate success
#
echo 'All Elastic Stack resources were deployed successfully'
