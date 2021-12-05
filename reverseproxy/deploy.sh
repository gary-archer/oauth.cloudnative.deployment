#!/bin/bash

############################################################
# Deploy the reverse proxy and expose it outside the cluster
############################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create the configmap for API routes
#
kubectl -n deployed delete configmap kong-config 2>/dev/null
kubectl -n deployed create configmap kong-config --from-file=kong-routes.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Kong routes configmap'
  exit 1
fi

#
# Create a config map for the custom plugin
#
kubectl -n deployed delete configmap kong-bff-token 2>/dev/null
kubectl -n deployed create configmap kong-bff-token --from-file=../resources/kong-bff-plugin/plugin
if [ $? -ne 0 ];
then
  echo "Problem encountered creating the Kong BFF blugin configmap"
  exit 1
fi

#
# Trigger deployment of the reverse proxy to the Kubernetes cluster
#
kubectl -n deployed delete -f kong-proxy.yaml 2>/dev/null
kubectl -n deployed apply  -f kong-proxy.yaml
if [ $? -ne 0 ]; then
  echo '*** Kong reverse proxy deployment problem encountered'
  exit 1
fi