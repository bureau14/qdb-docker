#!/usr/bin/env bash
# Setup SUT
docker-compose -f sut/docker-compose.yml up -d

# Start cypress in interactive mode
# Requires local cypress install
cypress open -P tester $@