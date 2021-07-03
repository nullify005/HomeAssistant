#!/bin/bash

docker build app/ -t nullify005/home-assistant:latest
docker push nullify005/home-assistant:latest
