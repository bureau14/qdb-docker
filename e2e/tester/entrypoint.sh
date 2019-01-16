#!/usr/bin/env bash

set -e

WAIT_ON=node_modules/wait-on/bin/wait-on
CYPRESS=node_modules/cypress/bin/cypress

DASHBOARD_URI=http://sut-qdb-dashboard:40000

echo "Waiting for dashboard at $DASHBOARD_URI"
${WAIT_ON} -t 10000 ${DASHBOARD_URI}
${CYPRESS} run $@
chmod -R a+rw ./cypress/reports ./cypress/screenshots ./cypress/videos
