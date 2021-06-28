#!/bin/bash

set -ex

kup_args="--user ubuntu --ssh-key HomeAssistant.id_rsa"

case ${1} in
  up)
    pulumi up --yes
    agentIp=$(pulumi stack output | grep agentIp | awk '{print $2}' | tr -d '\n')
    masterIp=$(pulumi stack output | grep masterIp | awk '{print $2}' | tr -d '\n')
    k3sup install --ip ${masterIp} ${kup_args}
    export KUBECONFIG=kubeconfig
    k3sup join --ip ${agentIp} --server-ip ${masterIp} ${kup_args}
    ;;
  destroy)
    pulumi destroy --yes
    ;;
  preview)
    pulumi preview
    ;;
  *)
    echo "${0} (up|destroy)"
    ;;
esac
