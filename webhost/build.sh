#!/bin/bash

###############################################
# Build the Web Host's code into a Docker image
###############################################

#
# Ensure that we are in the root folder
#
cd "$(dirname "${BASH_SOURCE[0]}")"
cd ..

#
# Get the final web sample
#
rm -rf resources/finalweb
git clone https://github.com/gary-archer/oauth.websample.final resources/finalweb
if [ $? -ne 0 ]; then
  echo '*** Web sample download problem encountered'
  exit 1
fi

#
# Build Javascript bundles
#
cd resources/finalweb/spa
npm install
npm run buildRelease
if [ $? -ne 0 ]; then
  echo '*** SPA build problem encountered'
  exit 1
fi

#
# Build Javascript bundles
#
cd ../webhost
npm install
npm run buildRelease
if [ $? -ne 0 ]; then
  echo '*** Web Host build problem encountered'
  exit 1
fi

#
# Build the Docker image
#
cp ../../../certs/default.svc.cluster.local.ca.pem ./trusted.ca.pem
cd ..
docker build --no-cache -f webhost/Dockerfile -t webhost:v1 .
if [ $? -ne 0 ]; then
  echo '*** Web Host docker build problem encountered'
  exit 1
fi

#
# Load it into kind's Docker registry
#
kind load docker-image webhost:v1 --name oauth
if [ $? -ne 0 ]; then
  echo '*** Web Host docker deploy problem encountered'
  exit 1
fi
