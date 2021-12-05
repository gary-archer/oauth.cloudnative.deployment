#!/bin/bash

#################################################################################################
# Base setup for a cluster with 2 virtual machines (nodes), after running 'brew install minikube'
#################################################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Tear down the cluster if it exists already
#
minikube delete --profile oauth 2>/dev/null
minikube start --nodes 2 --cpus=4 --memory=16384 --disk-size=50g --driver=hyperkit --profile oauth
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Kubernetes cluster'
  exit 1
fi

#
# Create a 'deployed' namespace for our apps
#
kubectl apply -f base/namespace.yaml
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Kubernetes namespace'
  exit 1
fi

#
# Ensure that components can be exposed from the cluster over port 443 to the developer machine
#
minikube addons enable ingress --profile oauth
if [ $? -ne 0 ]; then
  echo "*** Problem encountered enabling the ingress addon for the cluster"
  exit 1
fi

#
# When using self signed certificates in development environments we must run this
#
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission

#
# Enable the use of local registries
#
#minikube addons enable registry --profile oauth
if [ $? -ne 0 ]; then
  echo '*** Problem encountered enabling the minikube registry addon'
  exit 1
fi

#
# Run a registry from which Kubernetes can pull locally built Docker images
#
#docker container stop registry  1>/dev/null 2>&1
#docker container rm -v registry 1>/dev/null 2>&1
#docker run -d -p 5000:5000 --restart=always --name registry registry:2
if [ $? -ne 0 ]; then
  echo '*** Problem encountered starting the Docker registry'
  exit 1
fi

#
# Enable nodes to pull images from the host
#
#case "$(uname -s)" in
#  Darwin)
#    docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:host.docker.internal:5000"
# 	;;
#
#  MINGW64*)
#    docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"
#	;;
#esac

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
# Indicate success
#
echo 'Cluster was created successfully'
