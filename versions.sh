#!/bin/bash

source "utils.sh"

QDB_VERSION= # full version name, ex: 3.2.0master
QDB_CLEAN_VERSION= # version name without suffix, ex: 3.2.0
QDB_SHORT_VERSION= # short version name without suffix, ex: 3.2
QDB_LATEST_VERSION=3.1.0
QDB_NIGHTLY_VERSION=3.2.0

# detect_version: Detects qdb version
function detect_version {
    local server_file=`ls qdb-*-server.tar.gz`
    if [[ ${server_file} =~ (qdb-(.+)-linux-64bit-server.tar.gz$) ]]; then
        QDB_VERSION=${BASH_REMATCH[2]}
        if [[ ${QDB_VERSION} =~ (^(([0-9].[0-9]).[0-9]).*) ]]; then
            QDB_CLEAN_VERSION=(${BASH_REMATCH[2]})
            QDB_SHORT_VERSION=(${BASH_REMATCH[3]})
        fi
        echo "version: $QDB_VERSION"
        echo "clean version: $QDB_CLEAN_VERSION"
        return 0
    else
        echo "version not found, aborting..."
        return 1
    fi
}
