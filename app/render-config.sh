#!/bin/bash

# a shell script to roll out a real config folder from the template
# substituting values in the template from the secrets in order to push clean
# containers to the registry

set -ex
cp -Rv /config.tmpl/. /config/
gomplate -d secrets=/.secrets/secrets.yaml \
  --input-dir /config/.storage.tmpl/ --output-dir /config/.storage/
rm -rf /config/.storage.tmpl
# in compose land we have to sleep forever to stop the container from restarting all the time
if [ "${DOCKER_COMPOSE}" ]; then sleep infinity; fi
