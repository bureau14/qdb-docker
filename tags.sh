#!/bin/bash

TAGS=()

CURRENT_DOC_TAG=""
DOC_TAGS=()

# create_tags: Creates tags based on the version detected
function create_tags {
    TAGS+=($QDB_CLEAN_VERSION)
    if [[ ${QDB_CLEAN_VERSION} == $QDB_LATEST_VERSION ]]
    then
        TAGS+=("latest")
    fi

    if [[ ${QDB_CLEAN_VERSION} == $QDB_NIGHTLY_VERSION ]]
    then
        TAGS+=("nightly")
    fi

    local result=$(is_most_recent_version)
    if [[ "${result}" == "true" ]]
    then
        TAGS+=($QDB_VERSION_PREFIX)
    fi
}

#create_documentation_tags: Creates all tags for documentation purpose
function create_documentation_tags {
    for version in ${QDB_VERSIONS[@]}; do
        CURRENT_DOC_TAG=""
        add_doc_tag $version
        for recent_version in ${QDB_MOST_RECENT_VERSIONS[@]}; do
            if [[ $recent_version == $version ]]; then
                if [[ $recent_version =~ (^([0-9].[0-9]).[0-9].*) ]]; then
                    local version_prefix=${BASH_REMATCH[2]}
                    add_doc_tag $version_prefix
                fi
            fi
        done
        if [[ $version == $QDB_LATEST_VERSION ]]; then
            add_doc_tag "latest"
        fi
        if [[ $version == $QDB_NIGHTLY_VERSION ]]; then
            add_doc_tag "nightly"
        fi
        DOC_TAGS+=($CURRENT_DOC_TAG)
    done
}

function add_doc_tag {
    if [[ ${#CURRENT_DOC_TAG} -ne 0 ]]; then
        CURRENT_DOC_TAG="${CURRENT_DOC_TAG},"
    fi
    CURRENT_DOC_TAG="$CURRENT_DOC_TAG\t$1"
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
