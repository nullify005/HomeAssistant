# Home Assistant

## Overview

An [Home Assistant](https://www.home-assistant.io) repo & deployment for my own pleasure

- local & remote ks3 environments
- remote provisioned on lightsail using pulumi
- base cluster setup includes traefik, cert-manager + issuer for TLS termination
- helm charts for home-assistant, freedns & the cluster-issuer
- home-assistant
  - stateless build
  - .storage stripped down to only what is necessary (ie. no user auth etc.)
  - run a pre step using gomplate to inject various secrets into .storage
  - in docker-compose & k8s run an init container to conduct the templating
  - config and automation in YAML
  - intesis integration for my AirCon
  - google_assistant integration because it's fun

## Local Environment

### Setup

```
cd stacks
brew install pulumi
```

- docker
- docker-compose
- aws cli & authentication
- helm3
- helmfile
- k3sup
- k3sd

### Assistant Configuration

Develop changes to the automation etc.
```
docker-compose up
```
Then use the UI at [http://localhost:8123](http://localhost:8123)

### Test Deployment

Test whether it deploys and operates within a local kubernetes correctly
```
cd stack
./local.sh up
cd ../
helmfile -e development apply
```

## Google Assistant Integration

from https://www.home-assistant.io/integrations/google_assistant/

## TODO

- fix the upstream lightsail ports problem
- automated deployment ...
