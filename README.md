# Cloud Native Deployment

Resources for deploying code samples to Kubernetes on a development computer.

## Overall System

URLs to go here

## Prerequisites

- brew install kind
- Allocate resources in Docker Desktop
- Ensure that openssl, curl and jq are installed

## Deploy the System

### Create the Cluster

```bash
./1-create-cluster.sh
```

### Create Certificates

```bash
./2-create-certs.sh
```

### Configure Domains

TODO

### Build Code

```bash
./3-build.sh
```

### Deploy the System

```bash
./4-build.sh
```

## Use the System

### Use the SPA

TODO

### Use the Mobile App

TODO

### Use the Desktop App

TODO

### Analyse Elasticsearch Logs

TODO
