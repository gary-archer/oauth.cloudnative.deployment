

#!/bin/bash

API_TECH=nodejs

###################################################
# Deploy the API and expose it to the host computer
###################################################

#
# Issue an internal SSL certificate for the API and a secret for its private key password
# Files issued are then present in the data output of this command:
# - kubectl get certificate demoapi-svc-internal-cert -o yaml
#
kubectl delete secret demoapi-pkcs12-password 2>/dev/null
kubectl create secret generic demoapi-pkcs12-password --from-literal=password='Password1'
kubectl apply -f kubernetes/internal-cert.yaml
if [ $? -ne 0 ];
then
  echo "API internal certificate problem encountered"
  exit 1
fi

#
# Deploy the API to the cluster
#
kubectl delete deploy/demoapi       2>/dev/null
kubectl delete service/demoapi-svc  2>/dev/null
kubectl apply -f kubernetes/service.yaml
if [ $? -ne 0 ];
then
  echo "API service deployment problem encountered"
  exit 1
fi

#
# Expose the API on the host developer PC unless we are using an API Gateway
#
kubectl delete -f kubernetes/ingress.yaml 2>/dev/null
kubectl apply -f kubernetes/ingress.yaml
if [ $? -ne 0 ];
  then
    echo "API ingress problem encountered"
    exit 1
fi