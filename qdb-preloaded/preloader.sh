#!/usr/bin/env bash
# This script is ran during qdb-preloaded's build-time
# It will use railgun to load data from each subdirectory of /datasets
# Each of this subdirectories should include a data.csv and a railgun-compatible config.json

set -e

touch ./qdbd.log                 # avoid tail complaining about a non-existing file
qdbd -d --security=false -l .
echo "Waiting for qdbd..."
grep -m 1 "successfully started quasardb daemon" <(tail -F ./qdbd.log)

for DATASET_DIR in `ls -d /datasets/*/`
do
    echo "Loading $DATASET_DIR..."

    qdb-railgun \
        --delimiter , \
        --with-header 1 \
        --config "$DATASET_DIR./config.json" \
        --file "$DATASET_DIR./data.csv"
done