

#!/bin/bash

###################################################
# Deploy the API and expose it to the host computer
###################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

TODO

#
# Create a config map for the API's JSON configuration file
#
kubectl -n deployed delete configmap api-config
kubectl -n deployed create configmap api-config --from-file=api.config.json
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Web Host config map'
  exit 1
fi

#
# Create a secret for the private key password of the certificate file cert-manager will create
#
kubectl -n deployed delete secret finalapi-pkcs12-password 2>/dev/null
kubectl -n deployed create secret generic finalapi-pkcs12-password --from-literal=password='Password1'
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Web Host certificate secret'
  exit 1
fi

#
# Create API resources to deploy it and expose it via ingress
#
kubectl -n deployed delete -f api.yaml 2>/dev/null
kubectl -n deployed apply  -f api.yaml
if [ $? -ne 0 ]; then
  echo '*** Web Host Kubernetes deployment problem encountered'
  exit 1
fi
