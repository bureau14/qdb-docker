#!/bin/bash

TAGS=()
NIGHTLY=0

# create_tags: Creates tags based on the version detected
function create_tags {
    TAGS+=($QDB_CLEAN_VERSION)
    if [[ ${QDB_CLEAN_VERSION} == $QDB_LATEST_VERSION ]]; then
        TAGS+=("latest")
    fi
    if [[ ${QDB_VERSION} =~ (master$) ]]; then
        TAGS+=("nightly")
        NIGHTLY=1
    fi
}

# print_tags: Prints the tags separated by a ','
function print_tags {
    echo -n "tags: "
    local sep=""
    for tag in ${TAGS[@]}; do
        printf "%s%s" $sep $tag
        sep=","
    done
    echo ""
}