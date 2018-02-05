#!/bin/bash

TAGS=()
ALL_TAGS=()
ALL_TAGS_VERSIONS=()

# create_tags: Creates tags based on the version detected
function create_tags {
    TAGS+=($QDB_CLEAN_VERSION)
    if [[ ${QDB_CLEAN_VERSION} == $QDB_LATEST_VERSION ]]; then
        TAGS+=("latest")
    fi
    if [[ ${QDB_CLEAN_VERSION} == $QDB_NIGHTLY_VERSION ]]; then
        TAGS+=("nightly")
    fi

    is_most_recent_version
    if [[ $? == 1 ]]; then
        TAGS+=($QDB_VERSION_PREFIX)
    fi
}

#create_documentation_tags: Creates all tags for documentation purpose
function create_documentation_tags {
    add_tag latest $QDB_LATEST_VERSION
    add_tag nightly $QDB_NIGHTLY_VERSION
    for version in ${QDB_MOST_RECENT_VERSIONS[@]}; do
        if [[ $version =~ (^([0-9].[0-9]).[0-9].*) ]]; then
            local version_prefix=${BASH_REMATCH[2]}
            add_tag $version_prefix $version
        fi
    done
    for version in ${QDB_VERSIONS[@]}; do
        add_tag $version $version
    done
}

function add_tag {
    ALL_TAGS+=($1)
    ALL_TAGS_VERSIONS+=($2)
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