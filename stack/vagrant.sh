#!/bin/bash

. K8S_VERSION

set -x
apt-get update
apt-get -y install curl
curl -sLS https://get.k3sup.dev | sh
k3sup install --local --local-path /vagrant/kubeconfig --no-extras --k3s-version ${K3S_VERSION}