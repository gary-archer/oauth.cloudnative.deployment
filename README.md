# Cloud Native Deployment

Resources for deploying code samples to Kubernetes on a development computer.

## External URLs

We will spin up a number of components for the Final SPA which run on these external URLs:

| Component | External URL | Description |
| --------- | ------------ | ----------- |
| Web Host | https://web.mycompany.com/spa | A development host to serve web static content for the SPA |
| Reverse Proxy | https://api.mycompany.com | The base URL for the reverse proxy that sits in front of APIs |
| Token Handler | https://api.mycompany.com/tokenhandler | The SPA calls the token handler via the reverse proxy to perform OAuth work |
| Business API | https://api.mycompany.com/api | The SPA calls the business API via the reverse proxy to get data |

## Prerequisites

- Install [Docker Desktop](https://www.docker.com/products/docker-desktop) and [Kubernetes in Docker](https://kind.sigs.k8s.io/docs/user/quick-start/)
- Also ensure that `openssl`, `curl` and `jq` are installed

## Deploy the System

First create the cluster:

```bash
./1-create-cluster.sh
```

Then create SSL certificates for inside and outside the cluster:

```bash
./2-create-certs.sh
```

Then build apps into Docker containers:

```bash
./3-build.sh
```

Then deploy apps to the Kubernetes cluster:

```bash
./4-deploy.sh
```

Later you can free all resources when required via this script:

```bash
./5-teardown.sh
```

## Enable Development URLs

Update the hosts file with these development domain names:

```text
127.0.0.1 localhost web.mycompany.com api.mycompany.com
:1        localhost
```

Then trust the root certificate authority at `certs\mycompany.ca.pem`.\
This is done by adding it to the macOS system keychain or Windows local computer certificate store.

## Use the System

Then sign in to the Single Page Application with these details:

| Field | Value |
| ----- | ----- |
| SPA URL | https://web.mycompany.com/spa |
| User Name | guestuser@mycompany.com |
| User Password | GuestPassword1 |

## View Kubernetes Resources

The deployment aims for a real world setup for a development computer, with multiple nodes:

```text
kubectl get nodes:

NAME                  STATUS   ROLES                  AGE   VERSION
oauth-control-plane   Ready    control-plane,master   15m   v1.21.1
oauth-worker          Ready    <none>                 15m   v1.21.1
oauth-worker2         Ready    <none>                 15m   v1.21.1
```

Application containers run on worker nodes within a `deployed` namespace:

```text
kubectl get pods -o wide -n deployed

NAME                           READY   STATUS    RESTARTS   AGE   IP           NODE         
finalapi-77b44bf64-gh646       1/1     Running   0          86s   10.244.1.6   oauth-worker 
finalapi-77b44bf64-kqnql       1/1     Running   0          86s   10.244.2.7   oauth-worker2
kong-proxy-57d5fcd47f-6blc4    1/1     Running   0          83s   10.244.1.8   oauth-worker 
network-multitool-9zmcx        1/1     Running   0          13m   10.244.2.3   oauth-worker2
network-multitool-mf5mn        1/1     Running   0          13m   10.244.1.3   oauth-worker 
tokenhandler-9fc86d5cc-lhqrs   1/1     Running   0          84s   10.244.1.7   oauth-worker 
tokenhandler-9fc86d5cc-s8wws   1/1     Running   0          84s   10.244.2.8   oauth-worker2
webhost-5f76fdcf46-lwsdb       1/1     Running   0          87s   10.244.2.6   oauth-worker2
webhost-5f76fdcf46-zsxr9       1/1     Running   0          87s   10.244.1.5   oauth-worker 
```
