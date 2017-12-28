#!/bin/bash

QDB_VERSION=
QDB_DEB_VERSION=1
TAGS=()
PACKAGES_NAMES=()
PACKAGES_FILES=()

## Functions ##

# add_package: Creates the necessary variables for later usage
# First parameter is the name of the package
# Next parameters are the files needed by the package
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

# build_package: Prints information about package being built, and build package
function build_package {
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
    echo "  - files:"
    for file in ${files[@]}; do
        echo "    - $file"
        cp ../$file $file
    done
    cp $package_path/* .
    echo -n "  - "; docker -l "error" build -q -t ${package_image}:build --build-arg QDB_VERSION=${package_version} .
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
TAR_QDB="qdb-${QDB_VERSION}-linux-64bit-server.tar.gz"
TAR_QDB_WEB_BRIDGE="qdb-${QDB_VERSION}-linux-64bit-web-bridge.tar.gz"
TAR_QDB_PHP="quasardb-${QDB_VERSION}.tgz"
EGG_QDB_PYTHON="quasardb-${QDB_VERSION}-py2.7-linux-x86_64.egg"
DEB_QDB="qdb-server_${QDB_VERSION}-${QDB_DEB_VERSION}.deb"
DEB_QDB_WEB_BRIDGE="qdb-web-bridge_${QDB_VERSION}-${QDB_DEB_VERSION}.deb"
DEB_QDB_UTILS="qdb-utils_${QDB_VERSION}-${QDB_DEB_VERSION}.deb"
DEB_QDB_API="qdb-api_${QDB_VERSION}-${QDB_DEB_VERSION}.deb"

create_tags
print_tags

add_package qdb $TAR_QDB
add_package qdb-dev $DEB_QDB $DEB_QDB_WEB_BRIDGE $DEB_QDB_UTILS $DEB_QDB_API $EGG_QDB_PYTHON $TAR_QDB_PHP
add_package qdb-dev-python $DEB_QDB $DEB_QDB_WEB_BRIDGE $DEB_QDB_UTILS $DEB_QDB_API $EGG_QDB_PYTHON
add_package qdb-http $TAR_QDB_WEB_BRIDGE


echo "------------------"
mkdir -p build
cd build
if [[ ${#PACKAGES_NAMES[@]} != ${#PACKAGES_FILES[@]} ]]; then
    echo "Wrong number of names or files bundle. Aborting..."
    exit -1
fi

for ((index=0; index < ${#PACKAGES_NAMES} ; index++)); do
    build_package ${PACKAGES_NAMES[$index]} ${PACKAGES_FILES[$index]}
    push_package ${PACKAGES_NAMES[$index]}
    echo "------------------"
done