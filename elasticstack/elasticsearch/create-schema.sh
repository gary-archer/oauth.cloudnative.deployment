#!/bin/bash

##########################################################################################################
# A script copied to the Elasticsearch container and run from there, since I do not want to expose the API
##########################################################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"
RESPONSE_FILE=./response.txt

#
# TODO: create the schema properly
#

#
# Run the script
#
HTTP_STATUS=$(curl -k -s -u 'elastic:Password1' 'https://elasticsearch-svc:9200' \
-o $RESPONSE_FILE -w '%{http_code}')
if [ $HTTP_STATUS != '200' ]; then
  echo "*** Problem encountered creating the Elasticsearch schema, status: $HTTP_STATUS"
  cat $RESPONSE_FILE
  exit 1
fi
