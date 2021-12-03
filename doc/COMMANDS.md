View nodes:

- kubectl get nodes -o wide

View pods and their nodes:

- kubectl get pods -n deployed -o wide

Remote to a pod:

- kubectl -n deployed exec -it pod/dnsutils-68bd8dc878-hphv6 -- bash