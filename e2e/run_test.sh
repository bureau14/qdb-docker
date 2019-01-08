#!/usr/bin/env bash
# First argument is the docker tag used for all the images tested (and tester)

# Setup SUT
docker-compose -f sut/docker-compose.yml up -d

# Build tester image
TESTER_IMAGE=$(docker build -q tester)

# Run E2E tests
ARTIFACTS_DIR=`pwd`/artifacts
docker run --network host                                               \
           --volume  "$ARTIFACTS_DIR/reports:/cypress/reports"          \
           --volume  "$ARTIFACTS_DIR/screenshots:/cypress/screenshots"  \
           --volume  "$ARTIFACTS_DIR/videos:/cypress/videos"            \
           ${TESTER_IMAGE} $@