#!/usr/bin/env bash

echo "Stopping existing SUT containers..."

docker stop sut-qdb-preloaded
docker stop sut-qdb-dashboard
true