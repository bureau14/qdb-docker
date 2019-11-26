#!/usr/bin/env bash

set -ex

docker ps | tail -n +2 | awk '{print $1}' | xargs docker rm -f
