#!/bin/bash

REPO="nullify005/home-assistant"
TAG="${1}"
if [ -z "${TAG}" ]; then echo "missing TAG var"; exit 1; fi
docker build app/ -t ${REPO}:${TAG}
docker push ${REPO}:${TAG}
# also retag as latest & push if we're not asking for development
if [ "${TAG}" != "development" ]; then
  docker tag ${REPO}:${TAG} ${REPO}:latest
  docker push ${REPO}:latest
fi
