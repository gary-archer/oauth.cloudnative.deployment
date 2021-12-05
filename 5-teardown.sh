#!/bin/bash

######################################################
# This deletes the cluster and other related resources
######################################################

#
# Delete the cluster
#
minikube delete --profile oauth

#
# Indicate success
#
echo 'All application resources were deleted successfully'
