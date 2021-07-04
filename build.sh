#!/bin/bash

REPO="nullify005/home-assistant"
TAG="${1}"
if [ -z "${TAG}" ]; then echo "missing TAG var"; exit 1; fi
docker build app/ -t ${REPO}:${TAG}
docker tag ${REPO}:${TAG} ${REPO}:latest
for t in ${TAG} latest; do
  docker push ${REPO}:${t}
done
