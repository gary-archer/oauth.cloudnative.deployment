#!/bin/bash

###################################################################################
# Create external certificates and configure cert-manager for internal certificates
###################################################################################

#
# First run the script to create certificates for external URLs
#
cd certs
./create-external.sh
if [ $? -ne 0 ]; then
  echo "whatevar"
  exit 1
fi

#
# Create a secret
#
kubectl delete secret mycluster-com-tls 2>/dev/null
kubectl create secret tls mycluster-com-tls --cert=./mycluster.ssl.pem --key=./mycluster.ssl.key
if [ $? -ne 0 ]
then
  echo "*** Problem creating ingress SSL wildcard secret ***"
  exit 1
fi

#
# Next deploy certificate manager, used to issue certificates for inside the cluster
# kubectl get all -n cert-manager
#
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml

#
# Wait for cert manager to initialize as described here, so that our root clister certificate is trusted
# https://github.com/jetstack/cert-manager/issues/3338#issuecomment-707579834
#
echo "*** Waiting for cainjector to inject CA certificates into web hook ..."
sleep 30