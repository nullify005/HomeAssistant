#!/bin/bash

set -o errexit
set -x

. K8S_VERSION

function drop {
  minikube delete
}

function base_apply {
  helmfile apply
}

function create {
  minikube start --kubernetes-version=${MINI_VERSION} --vm-driver=hyperkit
  minikube addons enable registry
  MINI_IP=$(minikube ip)
  cat <<EOF > ../secrets/metallb.yaml
configInline:
  address-pools:
  - name: generic-cluster-pool
    protocol: layer2
    addresses:
    - ${MINI_IP}-${MINI_IP}
EOF
}

## ----------------------------- MAIN --------------------------------- ##
case ${1} in
  down|drop|delete|destroy)
    drop
    ;;
  *)
    create
    wait
    base_apply
    ;;
esac
