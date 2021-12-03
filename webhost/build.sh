#!/bin/bash

###############################################
# Build the Web Host's code into a Docker image
###############################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Prepare folders
#
cd ..
mkdir -p resources
rm -rf resources/finalweb

#
# Get the final web sample
#
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
  echo '*** Web Host Docker build problem encountered'
  exit 1
fi

#
# Push the Docker image
#
docker tag webhost:v1 localhost:5000/webhost
docker push localhost:5000/webhost
if [ $? -ne 0 ]; then
  echo '*** Web Host Docker push problem encountered'
  exit 1
fi
