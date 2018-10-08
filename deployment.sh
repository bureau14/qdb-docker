#!/bin/bash

source "versions.sh"
source "tags.sh"
source "container.sh"
source "documentation.sh"
source "files.sh"

get_versions qdb-dev-python

detect_version
if [[ $? != 1 ]]; then
    exit -1
fi
normalize_versions
check_released_versions
if [[ $? != 1 ]]; then
    add_release_version
fi

create_most_recents_versions
create_nightly_version

# needs to be done after the QDB_VERSION has been set
set_files

create_tags
create_documentation_tags
print_tags

add_container qdb \
    $DEBIAN_PACKAGE_QDB

add_container qdbsh \
    $DEBIAN_PACKAGE_QDB_API \
    $DEBIAN_PACKAGE_QDB_UTILS

add_container qdb-dashboard \
    $DEBIAN_PACKAGE_QDB_API \
    $DEBIAN_PACKAGE_QDB_REST \
    $DEBIAN_PACKAGE_QDB_DASHBOARD

add_container qdb-dev \
    $DEBIAN_PACKAGE_QDB \
    $DEBIAN_PACKAGE_QDB_API \
    $DEBIAN_PACKAGE_QDB_UTILS \
    $DEBIAN_PACKAGE_QDB_WEB_BRIDGE \
    $EGG_QDB_PYTHON \
    $TARBALL_QDB_PHP

add_container qdb-dev-python \
    $DEBIAN_PACKAGE_QDB \
    $DEBIAN_PACKAGE_QDB_API \
    $DEBIAN_PACKAGE_QDB_UTILS \
    $DEBIAN_PACKAGE_QDB_WEB_BRIDGE \
    $EGG_QDB_PYTHON



echo "Number of container: ${#CONTAINERS_NAMES[@]}"
echo "------------------"
mkdir -p build
cd build
if [[ ${#CONTAINERS_NAMES[@]} != ${#CONTAINERS_FILES[@]} ]]; then
    echo "Wrong number of names or files bundle. Aborting..."
    exit -1
fi

for ((index=0; index < (${#CONTAINERS_NAMES[@]} +1) ; index++)); do
    if [[ ! -z "${CONTAINERS_NAMES[$index]}" ]]; then
        print_info_container ${CONTAINERS_NAMES[$index]} ${CONTAINERS_FILES[$index]}
        build_container ${CONTAINERS_NAMES[$index]} ${CONTAINERS_FILES[$index]}
        if [[ $? != -1 ]]; then
            push_container ${CONTAINERS_NAMES[$index]}
            update_documentation ${CONTAINERS_NAMES[$index]} ${CONTAINERS_FILES[$index]}
        fi
        echo "------------------"
    fi
done
cd -
