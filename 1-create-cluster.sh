#!/bin/bash

##################################################################################################
# Base setup for a KIND cluster with 2 virtual machines (nodes), after running 'brew install kind'
##################################################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Tear down the cluster if it exists already
#
kind delete cluster --name 'oauth' 2>/dev/null

#
# Create the cluster
#
kind create cluster --config base/cluster.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Kubernetes cluster'
  exit 1
fi

#
# Apply labels to nodes
#
kubectl label nodes oauth-worker  role=worker
kubectl label nodes oauth-worker2 role=worker

#
# Create a 'deployed' namespace for our apps
#
kubectl apply -f base/namespace.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Kubernetes namespace'
  exit 1
fi

#
# Deploy a utility POD for troubleshooting
# https://github.com/Praqma/Network-MultiTool
#
cd utils
kubectl apply -f network-multitool.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered deploying troubleshooting tools'
  exit 1
fi

#
# Wait for the pod to reach a ready state
#
kubectl rollout status daemonset/network-multitool -n deployed

#
# Indicate success, and show the nodes with utility pods
#
kubectl get pods -n deployed -o wide
echo 'Cluster was created successfully'
