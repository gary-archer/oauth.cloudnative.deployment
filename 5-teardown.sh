#!/bin/bash

######################################################
# This deletes the cluster and other related resources
######################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Delete the cluster
#
minikube delete --profile oauth

#
# Indicate success
#
echo 'All application resources were deleted successfully'
