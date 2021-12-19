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
#kubectl -n elasticstack delete -f ./elasticstack/namespace.yaml 2>/dev/null
#kubectl -n elasticstack apply  -f ./elasticstack/namespace.yaml
if [ $? -ne 0 ]; then
  echo '*** Elastic Stack namespace creation problem encountered'
  exit 1
fi

#
# Deploy a secret for the internal root CA, used by the cluster issuer
#
#kubectl -n elasticstack delete secret default-svc-cluster-local 2>/dev/null
#kubectl -n elasticstack create secret tls default-svc-cluster-local --cert=./certs/default.svc.cluster.local.ca.pem --key=./certs/default.svc.cluster.local.ca.key
if [ $? -ne 0 ]; hen
  echo '*** Problem creating secret for the Elastic Stack internal SSL Root Authority ***'
  exit 1
fi

#
# Deploy the cluster issuer for the elastic namespace
#
#kubectl -n elasticstack apply -f ./base/clusterIssuer.yaml
if [ $? -ne 0 ]; hen
  echo '*** Problem creating the cluster issuer for the Elastic Stack namespace ***'
  exit 1

#
# Create a secret for the private key password of the Elasticsearch certificate that cert-manager will create
#
#kubectl -n elasticstack delete secret elasticsearch-pkcs12-password 2>/dev/null
#kubectl -n elasticstack create secret generic elasticsearch-pkcs12-password --from-literal=password='Password1'
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Elasticsearch certificate secret'
  exit 1
fi

#
# Trigger deployment of Elasticsearch to the Kubernetes cluster
#
#kubectl -n elasticstack delete -f elasticsearch.yaml 2>/dev/null
#kubectl -n elasticstack apply  -f elasticsearch.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered deploying Elasticsearch'
  exit 1
fi

#
# Run a Job to initialize Elasticsearch data once the system is up
#
#kubectl -n elasticstack delete -f elasticsearch-init.yaml 2>/dev/null
#kubectl -n elasticstack apply  -f elasticsearch-init.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered initializing Elasticsearch data'
  exit 1
fi

#
# Create a secret for the private key password of the Kibana certificate that cert-manager will create
#
kubectl -n elasticstack delete secret kibana-pkcs12-password 2>/dev/null
kubectl -n elasticstack create secret generic kibana-pkcs12-password --from-literal=password='Password1'
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Kibana certificate secret'
  exit 1
fi

#
# Trigger deployment of Kibana to the Kubernetes cluster
#
kubectl -n elasticstack delete -f kibana.yaml 2>/dev/null
kubectl -n elasticstack apply  -f kibana.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered deploying Kibana'
  exit 1
fi

#
# Indicate success
#
echo 'All Elastic Stack resources were deployed successfully'
