#!/usr/bin/env bash

set -e

URI="qdb://qdb-server:2836"

if [ "${QDB_URI}" != "" ]
then
    echo "Using cluster uri: ${QDB_URI}"
    URI=${QDB_URI}
fi

ALLOWED_ORIGIN="http://0.0.0.0:3449"
if [ "${QDB_ALLOWED_ORIGIN}" != "" ]
then
    echo "Adding allowed origin: ${QDB_ALLOWED_ORIGIN}"
    ALLOWED_ORIGIN=${QDB_ALLOWED_ORIGIN}
fi

cat /etc/qdb/qdb_rest.conf \
    | jq ".allowed_origins = [\"${ALLOWED_ORIGIN}\"]" \
    | jq ".assets = \"/var/lib/qdb/assets\"" \
    | jq ".cluster_uri = \"${URI}\"" \
    | jq ".host = \"0.0.0.0\"" \
    | jq ".port = \"40000\"" \
    | jq ".tls_certificate = \"\"" \
    | jq "del(.tls_key)"  \
    | jq "del(.cluster_public_key_file)" \
    > /tmp/qdb_rest.conf.new && \
    mv /tmp/qdb_rest.conf.new /etc/qdb/qdb_rest.conf && \
    chown qdb:qdb /etc/qdb/qdb_rest.conf

/usr/bin/qdb_rest --config-file /etc/qdb/qdb_rest.conf
