#!/bin/bash

####################################################
# Deploy the base Elasticsearch service and database
####################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

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
# TODO: use an init container
#
exit
echo 'Waiting for the Elasticsearch service to come up ...'
while [ "$(curl -k -s -o /dev/null -w ''%{http_code}'' -u "$ADMIN_USER:$ADMIN_PASSWORD" "$RESTCONF_BASE_URL?content=config")" != "200" ]; do
  sleep 2
done

#
# TODO: run create script
#
HTTP_STATUS=$(curl -k -s -u "$ELASTIC_USER:$ELASTIC_PASSWORD" 'https://elasticsearch-svc:9200' \
-o $RESPONSE_FILE -w '%{http_code}')
if [ $HTTP_STATUS != '200' ]; then
  echo "*** Problem encountered creating the Elasticsearch schema, status: $HTTP_STATUS"
  cat $RESPONSE_FILE
  exit 1
fi
