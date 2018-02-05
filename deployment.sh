#!/bin/bash

source "versions.sh"
source "tags.sh"
source "package.sh"
source "documentation.sh"
source "files.sh"

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

create_most_recents_versions
create_nightly_version

# needs to be done after the QDB_VERSION has been set
set_files

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
