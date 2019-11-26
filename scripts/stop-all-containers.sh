#!/usr/bin/env bash

set -ex

CONTAINERS=$(docker ps | tail -n +2 | awk '{print $1}')

for CONTAINER in ${CONTAINERS}
do
    echo "Removing container: ${CONTAINER}"
    docker rm -f ${CONTAINER}
done
