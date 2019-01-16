#!/bin/bash

CONTAINERS_NAMES=()
CONTAINERS_FILES=()

# add_container: Creates the necessary variables for later usage
# $1: the name of the container
# $[1:@]:  the files needed by the container
function add_container {
    local files=()
    local args=($@)
    local sep=
    local index=

    for ((index=1; index < ${#args} ; index++)); do
        if [[ ! -z "${args[$index]}" ]]; then
            files+=$sep
            files+=${args[$index]}
        fi
        sep=';'
    done
    CONTAINERS_NAMES+=($1)
    CONTAINERS_FILES+=($files)
}

# print_info_container: prints information about container
function print_info_container {
    local container_name=$1
    local container_image="bureau14/${container_name}"
    local container_path="../$container_name"
    # create array of files from a single line with ';' separator
    IFS=';' read -ra files <<< "$2"
    echo "container: $container_name"
    echo -n "  - "; print_tags
    echo "  - image: $container_image"
    echo "  - path: $container_path"
    echo "  - required:"
    for file in ${files[@]}; do
        echo "    - $file"
    done
}

# build_container: builds container
function build_container {
    local container_name=$1
    local container_image="bureau14/${container_name}"
    local container_path="../$container_name"

    local build_args=""
    if [[ "${container_name}" == "qdb-preloaded" ]]
    then
        build_args="${build_args} --build-arg BASE_IMAGE=bureau14/qdb:build"
    fi

    # create array of files from a single line with ';' separator
    IFS=';' read -ra files <<< "$2"
    for file in ${files[@]}
    do
        if [[ ! -f ../$file ]]
        then
            echo "Required file $file was not found, aborting build..."
            return -1
        fi
        cp ../$file $file
    done
    cp -R $container_path/* .
    echo -n "key :: "; docker -l "error" build -t ${container_image}:build  ${build_args} .
}

# push_container: Attach tags to built image and push container to docker
function push_container {
    local container_name=$1
    local container_image="bureau14/${container_name}"
    for TAG in ${TAGS[@]}; do
        docker tag ${container_image}:build ${container_image}:$TAG
        docker push ${container_image}:$TAG
    done
}
