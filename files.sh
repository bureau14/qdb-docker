#!/bin/bash

function find_file {
    local file=$1
    local expanded=$(echo ${file})
    local count=$(ls -lq ${expanded} | wc -l)

    if [ "$count" -eq "0" ]
    then
        echo "File not found: ${file}"
        exit -1
    fi

    if [ "$count" -ne "1" ]
    then
        echo "Found multiple matches for ${file}: ${expanded}"
        echo "Only a single file should be matched"
        exit -1
    fi

    echo ${expanded}
}

function set_files {
    TARBALL_QDB=$(find_file 'qdb-*-server.tar.gz')
    TARBALL_QDB_API=$(find_file 'qdb-*-c-api.tar.gz')
    # TARBALL_QDB_REST=$(find_file 'qdb-*-rest.tar.gz')
    TARBALL_QDB_UTILS=$(find_file 'qdb-*-utils.tar.gz')
    JAR_QDB_KINESIS_CONNECTOR=$(find_file 'kinesis-*-jar-with-dependencies.jar')
}
