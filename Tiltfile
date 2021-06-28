# -*- mode: Python -*-

load('ext://namespace', 'namespace_create', 'namespace_inject')

# Helper function to read K8s config YAML from helmfile.
#
# Currently `helmfile template` has a bug where it prints messages to stdout instead of stderr
# https://github.com/roboll/helmfile/issues/551
# So we use the workaround suggested there.
def helmfile(file):
  return local("helmfile -f %s template | grep -v -e '^Decrypting .*' | grep -v -e '^Fetching .*' | grep -v 'as it is not a table.$'" % (file))

allow_k8s_contexts('k3s-default')
docker_build('nullify/home-assistant', './app/')
ns='home-assistant'
namespace_create(ns)
k8s_resource('home-assistant')
k8s_yaml(namespace_inject(helmfile('helmfile.yaml'), ns))
