#!/bin/bash

##########################################
# Build the API's code into a Docker image
##########################################

API_TECH=nodejs

#
# Build the Node.js API
#
if [ "$API_TECH" == 'nodejs']; then

  git clone ...
  
  cd ..
  npm install
  npm run buildRelease
  if [ $? -ne 0 ];
  then
    echo "API build problem encountered"
    exit 1
  fi

  docker build --no-cache -f kubernetes/Dockerfile -t demoapi:v1 .
  if [ $? -ne 0 ];
  then
    echo "API docker build problem encountered"
    exit 1
  fi
fi