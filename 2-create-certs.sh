#!/bin/bash

#####################################################################
# Create resources needed for SSL both inside and outside the cluster
#####################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

# First run the script to create certificates for external URLs
#
cd certs
./create-external.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Create a secret for external URLs
#
kubectl -n deployed delete secret mycluster-com-tls 2>/dev/null
kubectl -n deployed create secret tls mycluster-com-tls --cert=./mycluster.ssl.pem --key=./mycluster.ssl.key
if [ $? -ne 0 ]; then
  echo '*** Problem creating ingress SSL wildcard secret'
  exit 1
fi

#
# Next deploy certificate manager, used to issue certificates to applications inside the cluster
# kubectl get all -n cert-manager
#
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml

#
# Wait for cert manager to initialize as described here, so that our root cluster certificate is trusted
# https://github.com/jetstack/cert-manager/issues/3338#issuecomment-707579834
#
echo 'Waiting for cainjector to inject CA certificates into web hook ...'
sleep 30

#
# Next create the Root CA for SSL inside the cluster
#
./create-internal.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Deploy a secret for the internal root CA, used by the cluster issuer
#
kubectl -n deployed delete secret default-svc-cluster-local 2>/dev/null
kubectl -n deployed create secret tls default-svc-cluster-local --cert=./default.svc.cluster.local.ca.pem --key=./default.svc.cluster.local.ca.key
if [ $? -ne 0 ]; then
  echo '*** Problem creating secret for internal SSL Root Authority ***'
  exit 1
fi

#
# Create a configmap for the Root CA
#
kubectl -n deployed delete configmap internal-root-ca 2>/dev/null
kubectl -n deployed create configmap internal-root-ca --from-file=./certs/default.svc.cluster.local.ca.pem
if [ $? -ne 0 ]; then
  echo '*** Problem creating a configmap for the internal SSL Root Authority ***'
  exit 1
fi

#
# Create the cluster issuer
#
kubectl -n deployed apply -f ./clusterIssuer.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem creating the cluster issuer'
  exit 1
fi

#
# Indicate success, and show the cert-manager nodes and pods
#
kubectl get pods -n cert-manager -o wide
echo 'All certificate resources were created successfully'