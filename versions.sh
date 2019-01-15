#!/bin/bash

source "utils.sh"

QDB_VERSION= # full version name, ex: 3.2.0master

# detect_version: Detects qdb version
function detect_version {
    local server_file=`ls qdb-*-server.tar.gz`
    if [[ ${server_file} =~ (qdb-(.+)-linux-64bit-server.tar.gz$) ]]; then
        QDB_VERSION=${BASH_REMATCH[2]}
        echo "version: $QDB_VERSION"
        return 0
    else
        echo "version not found, aborting..."
        return 1
    fi
}
