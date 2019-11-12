#!/usr/bin/env bash

set -e

/opt/qdb/bin/qdbd &

tini -g -- start-notebook.sh
