# Home Assistant

## Overview

An [Home Assistant](https://www.home-assistant.io) repo & deployment for my own pleasure

## Local Environment

### Assistant Configuration

Develop changes to the automation etc.
```
docker-compose up
```
Then use the UI at [http://localhost:8123](http://localhost:8123)

### Test Deployment

Test whether it deploys and operates within a local kubernetes correctly
```
./runtime.sh
tilt up
```

## TODO

- public dns zone
- TLS fronting
- production deployment
- google auth
- MFA
- google assistant integration
- traefik setup & understanding
- run locally in k8s
- helm chart
- CIS 1.6 for the container runtime
- secrets deployment
- determine what needs to be kept config wise in .storage
- bom weather integration
