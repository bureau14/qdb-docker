#!/bin/bash

source "utils.sh"

# function update_releases {
#     string_qdb_versions=`join_by "," ${QDB_VERSIONS[@]}`
#     prepared_qdb_versions=`sed -e "s/\([0-9].[0-9].[0-9]\)/ \\\`\1\\\`/g" <<< "$string_qdb_versions"`

#     sed "1,/\[qdb-releases\]/{s|\[qdb-releases\]|$prepared_qdb_versions|}" "qdb/README.md.in" > qdb/README.md.tmp
# }

function update_latest {
    sed "1,/\[qdb-latest\]/{s|\[qdb-latest\]|$QDB_LATEST_VERSION|}" "qdb/README.md.in" > qdb/README.md.tmp
}


function update_nightly {
    sed -i "1,/\[qdb-nightly\]/{s|\[qdb-nightly\]|$QDB_CLEAN_VERSION|}" "qdb/README.md.tmp"
}

function update_releases_info {
    local release_info="|release|last update|\n"
    release_info+="|---|---|\n"
    for ((index=0; index < (${#QDB_VERSIONS[@]} +1) ; ++index)); do
        if [[ ! -z ${QDB_VERSIONS[$index]} ]]; then
            release_info+="|${QDB_VERSIONS[$index]}|${QDB_VERSIONS_DATE[$index]}|\n"
        fi
    done
    sed -i "1,/\[release-info\]/{s/\[release-info\]/$release_info/}" "qdb/README.md.tmp"
}

function update_documentation {
    update_latest
    if [[ $NIGHTLY == 1 ]]; then
        update_nightly
    fi
    update_releases_info
    mv "qdb/README.md.tmp" "qdb/README.md"
}
