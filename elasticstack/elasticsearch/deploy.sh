#!/bin/bash

####################################################
# Deploy the base Elasticsearch service and database
####################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Create the namespace for Elastic components
#
kubectl -n elasticstack delete -f namespace.yaml 2>/dev/null
kubectl -n elasticstack apply  -f namespace.yaml
if [ $? -ne 0 ]; then
  echo '*** Elasticsearch namespace creation problem encountered'
  exit 1
fi

#
# Create a secret for the private key password of the certificate file cert-manager will create
#
kubectl -n elasticstack delete secret elasticsearch-pkcs12-password 2>/dev/null
kubectl -n elasticstack create secret generic elasticsearch-pkcs12-password --from-literal=password='Password1'
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Elasticsearch certificate secret'
  exit 1
fi

#
# Trigger deployment of Elasticsearch to the Kubernetes cluster
#
kubectl -n elasticstack delete -f elasticsearch.yaml 2>/dev/null
kubectl -n elasticstack apply  -f elasticsearch.yaml
if [ $? -ne 0 ]; then
  echo '*** Elasticsearch Kubernetes deployment problem encountered'
  exit 1
fi

#
# Wait for it to become ready
#
kubectl -n elasticstack rollout status deployment/elasticsearch

#
# TODO:
# - Remote to the pod and check certs + other files
# - See if I can use curl locally, else use network-multitool
# - Understand anything I need for API key setup
# - Then create the schema via kubectl (below)
# - Do this with invalid data initially to ensure that error handling works
#
exit

#
# Create the schema
#
ELASTICSEARCHPOD=$(kubectl get pod -n elasticstack -o name | grep elasticsearch)
kubectl -n elasticstack exec -it pod/$ELASTICSEARCHPOD -- bash \
curl -u "elastic:Password1" https://elasticsearch-svc:9200