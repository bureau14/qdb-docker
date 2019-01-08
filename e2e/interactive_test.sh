#!/usr/bin/env bash
# First argument is the docker tag used for all the images tested
TAG=$1
shift

# Setup SUT
sut/start.sh ${TAG}

# Start cypress in interactive mode
# Requires local cypress install
cypress open -P tester $@