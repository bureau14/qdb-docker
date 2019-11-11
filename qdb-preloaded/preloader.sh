#!/usr/bin/env bash
# This script is ran during qdb-preloaded's build-time
# It will use railgun to load data from each subdirectory of /opt/qdb/datasets
# Each of this subdirectories should include a data.csv and a railgun-compatible config.json

set -e

touch ./qdbd.log                 # avoid tail complaining about a non-existing file

/opt/qdb/bin/qdbd -d --security=false --rocksdb-root /opt/qdb/db -l .
echo "Waiting for qdbd..."
grep -m 1 "successfully started quasardb daemon" <(tail -F ./qdbd.log)

for DATASET_DIR in `ls -d /opt/qdb/datasets/*/`
do
    if [[ -f ${DATASET_DIR}/config.json && -f ${DATASET_DIR}/data.csv ]]
    then
        echo "Loading $DATASET_DIR..."
        LD_LIBRARY_PATH=/opt/qdb/lib/ /opt/qdb/bin/qdb_import \
            --config "$DATASET_DIR./config.json" \
            --file "$DATASET_DIR./data.csv"
    else
        echo "Skipping $DATASET_DIR -- does not contain both config.json and data.csv"
    fi
done

grep -m 1 "stable" <(tail -F ./qdbd.log)
