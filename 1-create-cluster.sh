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
# Apply labels which we'll later use to prevent deploying components to control plane nodes
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
# Deploy the NGINX ingress, which will create PODs in an ingress-nginx namespace
#
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
#if [ $? -ne 0 ]; then
#  echo '*** Problem encountered creating the Kubernetes namespace'
#  exit 1
#fi

#
# Wait for it to come up
#
#kubectl wait --namespace ingress-nginx \
#--for=condition=ready pod \
#--selector=app.kubernetes.io/component=controller \
#--timeout=90s

#
# When using self signed certificates in development environments we must run this
#
#kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission

#
# Deploy the MetalLB software load balancer in the metallb-system namespace
#
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kkubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered deploying software load balancer'
  exit 1
fi

#
# Get details for the local Docker kind network
#
#docker network inspect kind -f '{{.IPAM.config}}'

#
# Deploy a utility POD for troubleshooting
#
cd utils
kubectl -n deployed apply -f network-multitool.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered deploying troubleshooting tools'
  exit 1
fi

#
# Wait for the pod to reach a ready state
#
kubectl -n deployed rollout status daemonset/network-multitool

#
# Indicate success, and show the resulting nodes and pods
#
kubectl -n deployed get pods -o wide
echo 'Cluster was created successfully'
