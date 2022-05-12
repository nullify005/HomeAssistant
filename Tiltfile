# -*- mode: Python -*-

# Helper function to read K8s config YAML from helmfile.
#
# Currently `helmfile template` has a bug where it prints messages to stdout instead of stderr
# https://github.com/roboll/helmfile/issues/551
# So we use the workaround suggested there.
def helmfile(path):
  return local("helmfile -e development -f %s template | grep -v -e '^Decrypting .*' | grep -v -e '^Fetching .*' | grep -v 'as it is not a table.$'" % path)

# allow_k8s_contexts('default')
ns = 'home-assistant'
load('ext://namespace', 'namespace_create', 'namespace_inject')
docker_build("home-assistant", "./app")
namespace_create(ns)
# k8s_yaml(namespace_inject("./secrets.yaml", ns))
helm_yaml = helmfile("helmfile.d/")
k8s_yaml(namespace_inject(helm_yaml, ns))