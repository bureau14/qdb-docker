#!/bin/bash

PACKAGES_NAMES=()
PACKAGES_FILES=()

# add_package: Creates the necessary variables for later usage
# $1: the name of the package
# $[1:@]:  the files needed by the package
function add_package {
    local files=()
    local args=($@)
    local sep=
    for ((index=1; index < ${#args} ; index++)); do
        if [[ ! -z "${args[$index]}" ]]; then
            files+=$sep
            files+=${args[$index]}
        fi
        sep=';'
    done
    PACKAGES_NAMES+=($1)
    PACKAGES_FILES+=($files)
}

# print_info_package: prints information about package
function print_info_package {
    local package_name=$1
    local package_image="bureau14/$package_name"
    local package_path="../$package_name"
    local package_version=${QDB_VERSION}
    # create array of files from a single line with ';' separator
    IFS=';' read -ra files <<< "$2"
    echo "package: $package_name"
    echo "  - version: $package_version"
    echo -n "  - "; print_tags
    echo "  - image: $package_image"
    echo "  - path: $package_path"
    echo "  - required:"
    for file in ${files[@]}; do
        echo "    - $file"
    done
}

# build_package: builds package
function build_package {
    local package_name=$1
    local package_image="bureau14/${package_name}"
    local package_path="../$package_name"
    local package_version=${QDB_VERSION}
    # create array of files from a single line with ';' separator
    IFS=';' read -ra files <<< "$2"
    for file in ${files[@]}; do
        if [[ ! -f ../$file ]]; then
            echo "Required file $file was not found, aborting build..."
            return -1
        fi
        cp ../$file $file
    done
    cp $package_path/* .
    echo -n "key :: "; docker -l "error" build -q -t ${package_image}:build --build-arg QDB_VERSION=${package_version} .
}

# push_package: Attach tags to built image and push package to docker
function push_package {
    local package_name=$1
    local package_image="bureau14/${package_name}"
    for TAG in ${TAGS[@]}; do
        docker tag ${package_image}:build ${package_image}:$TAG
        # docker push ${package_image}:$TAG
    done
}
