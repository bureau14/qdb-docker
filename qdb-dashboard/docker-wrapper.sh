#!/usr/bin/env bash

set -e

if [ -z ${QDB_URI} ]; then
    IP=`which ip`
    AWK=`which awk`
    QDB_IP=`${IP} route get 8.8.8.8 | grep -oh 'src [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | awk '{print $2}'`
    QDB_URI="qdb://${QDB_IP}:2836"
fi

echo "Using cluster uri: ${QDB_URI}"

ALLOWED_ORIGIN="http://0.0.0.0:3449"
if [ "${QDB_ALLOWED_ORIGIN}" != "" ]
then
    echo "Adding allowed origin: ${QDB_ALLOWED_ORIGIN}"
    ALLOWED_ORIGIN=${QDB_ALLOWED_ORIGIN}
fi

cat /opt/qdb/etc/qdb_rest.conf.sample \
    | jq ".allowed_origins = [\"${ALLOWED_ORIGIN}\"]" \
    | jq ".assets = \"/opt/qdb/assets\"" \
    | jq ".cluster_uri = \"${QDB_URI}\"" \
    | jq ".host = \"0.0.0.0\"" \
    | jq ".port = 40080" \
    | jq ".tls_certificate = \"\"" \
    | jq "del(.tls_key)"  \
    | jq "del(.cluster_public_key_file)" \
    >  /opt/qdb/etc/qdb_rest.conf

LD_LIBRARY_PATH=/opt/qdb/lib/ /opt/qdb/bin/qdb_rest --config-file /opt/qdb/etc/qdb_rest.conf
