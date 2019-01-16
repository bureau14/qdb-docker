#!/usr/bin/env bash

# First argument is the docker tag used for all the images tested (and tester)
TAG=${1:-build}
shift

set -xe

# Setup SUT
sut/stop.sh
sut/start.sh ${TAG}

TESTER_IMAGE="e2e-tester:$TAG"

# Run E2E tests
ARTIFACTS_DIR=`pwd`/artifacts
docker run --network host                                               \
           --volume  "$ARTIFACTS_DIR/reports:/cypress/reports"          \
           --volume  "$ARTIFACTS_DIR/screenshots:/cypress/screenshots"  \
           --volume  "$ARTIFACTS_DIR/videos:/cypress/videos"            \
           ${TESTER_IMAGE} $@

# Stop SUT
sut/stop.sh
