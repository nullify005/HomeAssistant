#!/bin/bash

set -ex
STACK="nullify005/HomeAssistant/stag"
if [ "${2}" == "prod" ]; then
  STACK="nullify005/HomeAssistant/prod"
fi
pulumi stack select ${STACK}

. K3S_VERSION
kup_args="--user ubuntu --ssh-key ../secrets/HomeAssistant.id_rsa --k3s-version ${REMOTE_K3S_VERSION}"

case ${1} in
  up)
    pulumi up --yes
    sleep 60
    # agentIp=$(pulumi stack output | grep agent_ip | awk '{print $2}' | tr -d '\n')
    nodeIp=$(pulumi stack output | grep node_ip | awk '{print $2}' | tr -d '\n')
    k3sup install --ip ${nodeIp} ${kup_args}
    export KUBECONFIG=`pwd`/kubeconfig
    # k3sup join --ip ${agentIp} --server-ip ${masterIp} ${kup_args} --k3s-extra-args '--no-deploy traefik'
    helmfile apply
    ;;
  destroy)
    pulumi destroy --yes
    ;;
  preview)
    pulumi preview
    ;;
  *)
    echo "${0} (up|destroy|preview)"
    ;;
esac
