#!/bin/bash

source "utils.sh"

# function update_releases {
#     local package=$1
#     string_qdb_versions=`join_by "," ${QDB_VERSIONS[@]}`
#     prepared_qdb_versions=`sed -e "s/\([0-9].[0-9].[0-9]\)/ \\\`\1\\\`/g" <<< "$string_qdb_versions"`

#     sed "1,/\[qdb-releases\]/{s|\[qdb-releases\]|$prepared_qdb_versions|}" "qdb/README.md.in" > qdb/README.md.tmp
# }

function update_latest {
    local package=$1
    sed "1,/\[latest\]/{s|\[latest\]|$QDB_LATEST_VERSION|}" "../$package/README.md.in" > README.md.tmp
}


function update_nightly {
    sed -i "1,/\[nightly\]/{s|\[nightly\]|$QDB_CLEAN_VERSION|}" "README.md.tmp"
}

function update_releases_info {
    local release_info="|tag|version|\n"
    release_info+="|---|---|\n"
    for ((index_i=0; index_i < (${#ALL_TAGS[@]}) ; ++index_i)); do
        release_info+="|\`${ALL_TAGS[$index_i]}\`|${ALL_TAGS_VERSIONS[$index_i]}|\n"
    done
    sed -i "1,/\[release-info\]/{s/\[release-info\]/$release_info/}" "README.md.tmp"
}

function update_required_files {
    # create array of files from a single line with ';' separator
    IFS=';' read -ra fs <<< "$1"
    if [ ${#fs[@]} != 0 ]; then
        local required_files="\n"
        for file in ${fs[@]}; do
            f=`sed -e "s/$QDB_VERSION/{version}/g" <<< "$file"`
            required_files+="\t1. $f\n"
        done
    fi
    sed -i "1,/\[required-files\]/{s/\[required-files\]/$required_files/}" "README.md.tmp"
}

function update_documentation {
    local package=$1
    local files=$2
    update_latest $package
    if [[ $NIGHTLY == 1 ]]; then
        update_nightly
    fi
    update_releases_info
    update_required_files $files
    mv "README.md.tmp" "../$package/README.md"
}
