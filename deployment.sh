#!/bin/bash

source "versions.sh"
source "tags.sh"
source "package.sh"
source "documentation.sh"

get_versions qdb

detect_version
if [[ $? != 1 ]]; then
    exit -1
fi
normalize_versions
check_released_versions
if [[ $? != 1 ]]; then
    add_release_version
fi

create_most_recents
create_nightly_version


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
create_documentation_tags
print_tags

add_package qdb \
    $TARBALL_QDB

# add_package qdb-http \
#     $TARBALL_QDB_WEB_BRIDGE

# add_package qdb-dev \
#     $DEBIAN_PACKAGE_QDB \
#     $DEBIAN_PACKAGE_QDB_API \
#     $DEBIAN_PACKAGE_QDB_UTILS \
#     $DEBIAN_PACKAGE_QDB_WEB_BRIDGE \
#     $EGG_QDB_PYTHON \
#     $TARBALL_QDB_PHP

# add_package qdb-dev-python \
#     $DEBIAN_PACKAGE_QDB \
#     $DEBIAN_PACKAGE_QDB_API \
#     $DEBIAN_PACKAGE_QDB_UTILS \
#     $DEBIAN_PACKAGE_QDB_WEB_BRIDGE \
#     $EGG_QDB_PYTHON



echo "Number of package: ${#PACKAGES_NAMES[@]}"
echo "------------------"
mkdir -p build
cd build
if [[ ${#PACKAGES_NAMES[@]} != ${#PACKAGES_FILES[@]} ]]; then
    echo "Wrong number of names or files bundle. Aborting..."
    exit -1
fi

for ((index=0; index < (${#PACKAGES_NAMES[@]} +1) ; index++)); do
    if [[ ! -z "${PACKAGES_NAMES[$index]}" ]]; then
        print_info_package ${PACKAGES_NAMES[$index]} ${PACKAGES_FILES[$index]}
        build_package ${PACKAGES_NAMES[$index]} ${PACKAGES_FILES[$index]}
        if [[ $? != -1 ]]; then
            push_package ${PACKAGES_NAMES[$index]}
            update_documentation ${PACKAGES_NAMES[$index]} ${PACKAGES_FILES[$index]}
        fi
        echo "------------------"
    fi
done
cd -
