#!/bin/bash

##########################################
# Build the API's code into a Docker image
##########################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Check for a valid command line parameter
#
API_TECH="$1"
if [ "$API_TECH" != 'nodejs' ] && [ "$API_TECH" != 'netcore' ] && [ "$API_TECH" != 'java' ]; then
  echo 'An invalid API_TECH parameter was supplied'
  exit 1
fi

#
# Prepare folders
#
cd ../..
mkdir -p resources
rm -rf resources/finalapi

#
# Build the Node.js API
#
if [ "$API_TECH" == 'nodejs' ]; then
  
  git clone https://github.com/gary-archer/oauth.apisample.nodejs resources/finalapi
  
  cd resources/finalapi
  npm install
  npm run buildRelease
  if [ $? -ne 0 ];
  then
    echo '*** Node API build problem encountered'
    exit 1
  fi

  cp ../../certs/default.svc.cluster.local.ca.pem ./trusted.ca.pem
  docker build --no-cache -f Dockerfile -t finalapi:v1 .
  if [ $? -ne 0 ];
  then
    echo '*** Node API docker build problem encountered'
    exit 1
  fi
fi

#
# Build the .NET API
#
if [ "$API_TECH" == 'netcore' ]; then

  git clone https://github.com/gary-archer/oauth.apisample.netcore resources/finalapi

  cd resources/finalapi
  dotnet clean sampleapi.csproj
  dotnet publish sampleapi.csproj -c Release -r linux-x64
  if [ $? -ne 0 ]; then
    echo '*** .NET API build problem encountered'
    exit 1
  fi

  cp ../../certs/default.svc.cluster.local.ca.pem ./trusted.ca.pem
  docker build --no-cache -f Dockerfile -t finalapi:v1 .
  if [ $? -ne 0 ]; then
    echo "*** .NET API docker build problem encountered"
    exit 1
  fi
fi

#
# Build the Java API
#
if [ "$API_TECH" == 'java' ]; then

  git clone https://github.com/gary-archer/oauth.apisample.javaspringboot resources/finalapi

  cd resources/finalapi
  mvn clean install
  if [ $? -ne 0 ];
  then
    echo '*** Java API build problem encountered'
    exit 1
  fi

  cp ../../certs/default.svc.cluster.local.ca.pem ./trusted.ca.pem
  docker build --no-cache -f Dockerfile -t finalapi:v1 .
  if [ $? -ne 0 ];
  then
    echo '*** Java API docker build problem encountered'
    exit 1
  fi
fi