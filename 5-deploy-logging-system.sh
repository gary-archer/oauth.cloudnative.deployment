#!/bin/bash

###################################################################
# This deploys Elastic Stack containers into the Kubernetes cluster
###################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create the namespace for Elastic components
#
kubectl -n elasticstack delete -f ./elasticstack/namespace.yaml 2>/dev/null
kubectl -n elasticstack apply  -f ./elasticstack/namespace.yaml
if [ $? -ne 0 ]; then
  echo '*** Elastic Stack namespace creation problem encountered'
  exit 1
fi

#
# Deploy a secret for the internal root CA, used by the cluster issuer
#
kubectl -n elasticstack delete secret default-svc-cluster-local 2>/dev/null
kubectl -n elasticstack create secret tls default-svc-cluster-local --cert=./certs/default.svc.cluster.local.ca.pem --key=./certs/default.svc.cluster.local.ca.key
if [ $? -ne 0 ]; hen
  echo '*** Problem creating secret for the Elastic Stack internal SSL Root Authority ***'
  exit 1
fi

#
# Deploy the cluster issuer for the elastic namespace
#
kubectl -n elasticstack apply -f ./base/clusterIssuer.yaml
if [ $? -ne 0 ]; hen
  echo '*** Problem creating the cluster issuer for the Elastic Stack namespace ***'
  exit 1

#
# Deploy Elastic Stack resources
#
./elasticstack/elasticsearch/deploy.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# TODO: Kibana
#

#
# TODO: Filebeat
#

#
# Indicate success
#
echo 'All Elastic Stack resources were deployed successfully'
