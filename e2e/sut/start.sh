#!/usr/bin/env bash
set -e

TAG=$1

[ -z "$TAG" ] && echo "You must specify a docker tag" && exit 1

echo "Starting SUT containers with tag $TAG..."

docker run \
       -d \
       -p 2836:2836 \
       --name sut-qdb-preloaded \
       --rm \
       --env QDB_DISABLE_SECURITY=true \
       "bureau14/qdb-preloaded:$TAG"

docker run \
       -d \
       -p 40080:40080 \
       --name sut-qdb-dashboard \
       --rm \
       --link sut-qdb-preloaded:sut-qdb-preloaded \
       --env DEBUG=true \
       --env QDB_URI=qdb://sut-qdb-preloaded:2836 \
       "bureau14/qdb-dashboard:$TAG"
