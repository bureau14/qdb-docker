#!/bin/bash

TAGS=()

# create_tags: Creates tags based on the version detected
function create_tags {
    TAGS+=($QDB_CLEAN_VERSION)
    TAGS+=($QDB_SHORT_VERSION) # we suppose we are always updating the docker in chronological order, so 3.2.1 would come after 3.2.0
    if [[ ${QDB_CLEAN_VERSION} == $QDB_LATEST_VERSION ]]
    then
        TAGS+=("latest")
    fi

    if [[ ${QDB_CLEAN_VERSION} == $QDB_NIGHTLY_VERSION ]]
    then
        TAGS+=("nightly")
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
