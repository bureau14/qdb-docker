#!/usr/bin/env bash
set -e

TAG=$1

[ -z "$TAG" ] && echo "You must specify a docker tag" && exit 1

echo "Starting SUT containers with tag $TAG..."

docker run --name sut-qdb-preloaded --rm --network host --env QDB_DISABLE_SECURITY=true "bureau14/qdb-preloaded:$TAG" &
docker run --name sut-qdb-dashboard --rm --network host --env DEBUG=true "bureau14/qdb-dashboard:$TAG" &