#!/bin/bash

# desired cluster name (default is "k3s-default")
CLUSTER_NAME="${CLUSTER_NAME:-k3s-default}"
. K3S_VERSION
IMAGE_VERSION="rancher/k3s:${LOCAL_K3S_VERSION}"
# default name/port
# TODO(maia): support other names/ports
reg_name='registry.local'
reg_port='5000'

set -o errexit
set -x

function create {
  # Check if cluster already exists.
  # AFAICT there's no good way to get the registry name/port from a running
  # cluster, so if it already exists, just bail.
  MAKE_CLUSTER=1
  for cluster in $(k3d cluster list 2>/dev/null | grep -v NAME | awk '{print $1}'); do
    if [ "$cluster" == "$CLUSTER_NAME" ]; then
        # TODO(maia): check if the cluster already has the appropriate annotations--then we're okay
        # TODO(maia): if cluster exists, has registry, doesn't have annotations, apply them.
        #   (Unfortunately there's no easy way to check what registristry (if any) the cluster
        #   is running, see https://github.com/rancher/k3d/issues/193)
        echo "Cluster '$cluster' already exists, aborting script."
        echo -e "\t(You can delete the cluster with 'k3d cluster delete $CLUSTER_NAME' and rerun this script.)"
        MAKE_CLUSTER=0
    fi
  done
  if [ "${MAKE_CLUSTER}" -eq 1 ]; then
    k3d cluster create ${CLUSTER_NAME} --registry-create \
      -p "80:80@loadbalancer" -p "443:443@loadbalancer" --agents 2 \
      --k3s-server-arg '--no-deploy=traefik' \
      -i ${IMAGE_VERSION}
  fi
}

function wait {
  echo "Waiting for Kubeconfig to be ready..."
  timeout=$(($(date +%s) + 30))
  until [[ $(date +%s) -gt $timeout ]]; do
    if k3d kubeconfig get ${CLUSTER_NAME} > /dev/null 2>&1; then
      export KUBECONFIG="$(k3d kubeconfig write ${CLUSTER_NAME})"
      DONE=true
      break
    fi
    sleep 0.2
  done

  if [ -z "$DONE" ]; then
    echo "Timed out trying to get Kubeconfig"
    exit 1
  fi
}

function annotate {
  # Annotate nodes with registry info for Tilt to auto-detect
  echo "Waiting for node(s) + annotating with registry info..."
  DONE=""
  timeout=$(($(date +%s) + 30))
  until [[ $(date +%s) -gt $timeout ]]; do
    nodes=$(kubectl get nodes -o go-template --template='{{range .items}}{{printf "%s\n" .metadata.name}}{{end}}')
    if [ ! -z "${nodes}" ]; then
      for node in $nodes; do
        kubectl annotate node "${node}" \
          --overwrite=true \
          tilt.dev/registry=localhost:${reg_port} \
          tilt.dev/registry-from-cluster=${reg_name}:${reg_port}
      done
      DONE=true
      break
    fi
    sleep 0.2
  done
  if [ -z "$DONE" ]; then
    echo "Timed out waiting for node(s) to be up"
    exit 1
  fi
}

function context {
  echo "Set kubecontext with:"
  echo -e "\texport KUBECONFIG=\"\$(k3d kubeconfig write ${CLUSTER_NAME})\""
}

function drop {
  k3d cluster delete ${CLUSTER_NAME}
}

function base_apply {
  helmfile apply
}

## ----------------------------- MAIN --------------------------------- ##
case ${1} in
  down|drop|delete|destroy)
    drop
    ;;
  *)
    create
    wait
    annotate
    context
    base_apply
    ;;
esac
