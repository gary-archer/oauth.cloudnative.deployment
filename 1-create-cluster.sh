#!/bin/bash

###############################################################
# Base setup for a KIND cluster with 2 virtual machines (nodes)
###############################################################

#
# Create the cluster
#
kind create cluster --config base/cluster.yml
if [ $? -ne 0 ];
then
  echo 'Problem encountered creating the Kubernetes cluster'
  exit 1
fi

#
# Create a namespace for our apps
#
kubectl apply -f base/namespace.yml
if [ $? -ne 0 ];
then
  echo 'Problem encountered creating the Kubernetes namespace'
  exit 1
fi


#
# Deploy troubleshooting utilities
#
kubectl apply -f base/dnsutils.yml
if [ $? -ne 0 ];
then
  echo 'Problem encountered deploying utilities'
  exit 1
fi

#
# Tear down the cluster if required
#
#kind delete cluster --name 'oauth'

#
# Stop and restart the cluster
#
#kind restart cluster -- name 'oauth'

#
# Restarts
#
#https://github.com/kubernetes-sigs/kind/issues/148
#docker start kind-1-control-plane && docker exec kind-1-control-plane sh -c 'mount -o remount,ro /sys; kill -USR1 1'