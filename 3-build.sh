#!/bin/bash

#############################################################
# This builds code into Docker containers ready for deploying
#############################################################

API_TECH='nodejs'

#
# Run a registry that we will push locally built Docker images to
#
docker container stop registry  1>/dev/null 2>&1
docker container rm -v registry 1>/dev/null 2>&1
docker run -d -p 5000:5000 --restart=always --name registry registry:2
if [ $? -ne 0 ]; then
  echo '*** Problem encountered starting the Docker registry'
  exit 1
fi

#
# Enable nodes to pull images from the host
#
case "$(uname -s)" in
  Darwin)
    docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:host.docker.internal:5000"
 	;;

  MINGW64*)
    docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"
	;;
esac
if [ $? -ne 0 ]; then
  echo '*** Problem encountered setting up node connectivity to the Docker registry'
  exit 1
fi

#
# Build the web host
#
./webhost/build.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Build the API
#
./api/build.sh "$API_TECH"
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Indicate success
#
echo 'All application resources were built successfully'