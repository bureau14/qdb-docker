#!/bin/bash

QDB_VERSION=
QDB_DEB_VERSION=1
TAGS=()
PACKAGES_NAMES=()
PACKAGES_FILES=()

## Functions ##

# add_package: Creates the necessary variables for later usage
# $1: the name of the package
# $[1:@]:  the files needed by the package
function add_package {
    files=()
    args=($@)
    sep=
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

# detect_version: Detects qdb version
function detect_version {
    server_file=`ls qdb-server_*-1.deb`
    if [[ ${server_file} =~ (qdb-server_(.+)-1.deb$) ]]; then
        QDB_VERSION=${BASH_REMATCH[2]}
        echo "version: $QDB_VERSION"
        return 1
    else
        echo "version not found, aborting..."
    fi
}

# normalize_versions: Changes names for php tarball and python egg to match the other files 
function normalize_versions {
    php_tar=`ls quasardb-*.tgz`
    if [[ $php_tar != "quasardb-${QDB_VERSION}.tgz" ]];then
        mv $php_tar quasardb-${QDB_VERSION}.tgz
    fi
    python_egg=`ls quasardb-*-py2.7-linux-x86_64.egg`
    if [[ $python_egg != "quasardb-${QDB_VERSION}-py2.7-linux-x86_64.egg" ]];then
        mv $python_egg quasardb-${QDB_VERSION}-py2.7-linux-x86_64.egg
    fi
}

# create_tags: Creates tags based on the version detected
function create_tags {
    if [[ ${QDB_VERSION} =~ (^([0-9].[0-9].[0-9]).*) ]]; then
        TAGS+=(${BASH_REMATCH[2]})
    fi
    if [[ ${QDB_VERSION} =~ (master$) ]]; then
        TAGS+=("nightly")
    fi
}

# print_tags: Prints the tags separated by a ','
function print_tags {
    echo -n "tags: "
    sep=""
    for tag in ${TAGS[@]}; do
        printf "%s%s" $sep $tag
        sep=","
    done
    echo ""
}

# print_info_package: prints information about package
function print_info_package {
    package_name=$1
    package_image="bureau14/$package_name"
    package_path="../$package_name"
    package_version=${QDB_VERSION}
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
    package_name=$1
    package_image="bureau14/$package_name"
    package_path="../$package_name"
    package_version=${QDB_VERSION}
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
    package_name=$1
    package_image="bureau14/$package_name"
    for TAG in ${TAGS[@]}; do
        docker tag ${package_image}:build ${package_image}:$TAG
        # docker push ${package_image}:$TAG
    done
}

## Start of script ##

detect_version
if [[ $? != 1 ]]; then
    exit -1
fi
normalize_versions

# Needs to be done after QDB_VERSION has been set
TARBALL_QDB="qdb-${QDB_VERSION}-linux-64bit-server.tar.gz"
TARBALL_QDB_WEB_BRIDGE="qdb-${QDB_VERSION}-linux-64bit-web-bridge.tar.gz"
TARBALL_QDB_PHP="quasardb-${QDB_VERSION}.tgz"
EGG_QDB_PYTHON="quasardb-${QDB_VERSION}-py2.7-linux-x86_64.egg"
DEBIAN_PACKAGE_QDB="qdb-server_${QDB_VERSION}-${QDB_DEB_VERSION}.deb"
DEBIAN_PACKAGE_QDB_WEB_BRIDGE="qdb-web-bridge_${QDB_VERSION}-${QDB_DEB_VERSION}.deb"
DEBIAN_PACKAGE_QDB_UTILS="qdb-utils_${QDB_VERSION}-${QDB_DEB_VERSION}.deb"
DEBIAN_PACKAGE_QDB_API="qdb-api_${QDB_VERSION}-${QDB_DEB_VERSION}.deb"

create_tags
print_tags

add_package qdb \
    $TARBALL_QDB

add_package qdb-dev \
    $DEBIAN_PACKAGE_QDB \
    $DEBIAN_PACKAGE_QDB_API \
    $DEBIAN_PACKAGE_QDB_UTILS \
    $DEBIAN_PACKAGE_QDB_WEB_BRIDGE \
    $EGG_QDB_PYTHON \
    $TARBALL_QDB_PHP

add_package qdb-dev-python \
    $DEBIAN_PACKAGE_QDB \
    $DEBIAN_PACKAGE_QDB_API \
    $DEBIAN_PACKAGE_QDB_UTILS \
    $DEBIAN_PACKAGE_QDB_WEB_BRIDGE \
    $EGG_QDB_PYTHON

add_package qdb-http \
    $TARBALL_QDB_WEB_BRIDGE


echo "------------------"
mkdir -p build
cd build
if [[ ${#PACKAGES_NAMES[@]} != ${#PACKAGES_FILES[@]} ]]; then
    echo "Wrong number of names or files bundle. Aborting..."
    exit -1
fi

for ((index=0; index < (${#PACKAGES_NAMES} +1) ; index++)); do
    print_info_package ${PACKAGES_NAMES[$index]} ${PACKAGES_FILES[$index]}
    build_package ${PACKAGES_NAMES[$index]} ${PACKAGES_FILES[$index]}
    if [[ $? != -1 ]]; then
        push_package ${PACKAGES_NAMES[$index]}
    fi
    echo "------------------"
done
