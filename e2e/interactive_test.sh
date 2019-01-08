#!/usr/bin/env bash
# First argument is the docker tag used for all the images tested (and tester)
TAG=$1

# Setup SUT
sut/start.sh ${TAG}

# Start cypress in interactive mode
# Requires local cypress install
cypress open -P tester $@