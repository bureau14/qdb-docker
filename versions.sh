#!/bin/bash

source "utils.sh"

QDB_VERSION=
QDB_CLEAN_VERSION=
QDB_DEB_VERSION=1
QDB_LATEST_VERSION=2.2.0
QDB_VERSIONS=(2.1.0 2.2.0 2.3.0)
QDB_VERSIONS_DATE=(17-12-29T14:06:26 17-12-29T14:06:33 17-12-29T15:22:34)

# detect_version: Detects qdb version
function detect_version {
    local server_file=`ls qdb-server_*-1.deb`
    if [[ ${server_file} =~ (qdb-server_(.+)-1.deb$) ]]; then
        QDB_VERSION=${BASH_REMATCH[2]}
        if [[ ${QDB_VERSION} =~ (^([0-9].[0-9].[0-9]).*) ]]; then
            QDB_CLEAN_VERSION=(${BASH_REMATCH[2]})
        else
            echo "version is not a release version, aborting..."
            return 0
        fi
        echo "version: $QDB_VERSION"
        return 1
    else
        echo "version not found, aborting..."
    fi
}

# normalize_versions: Changes names for php tarball and python egg to match the other files 
function normalize_versions {
    local php_tar=`ls quasardb-*.tgz`
    if [[ $php_tar != "quasardb-${QDB_VERSION}.tgz" ]];then
        mv $php_tar quasardb-${QDB_VERSION}.tgz
    fi
    local python_egg=`ls quasardb-*-py2.7-linux-x86_64.egg`
    if [[ $python_egg != "quasardb-${QDB_VERSION}-py2.7-linux-x86_64.egg" ]];then
        mv $python_egg quasardb-${QDB_VERSION}-py2.7-linux-x86_64.egg
    fi
}

# check_released_versions: check if detected version matches an already released version
function check_released_versions {
    for version in ${QDB_VERSIONS[@]}; do
        if [ "$QDB_CLEAN_VERSION" == "$version" ]; then
            return 1
        fi
    done
}

# add_release_version: if version has not be found, add it
function add_release_version {
    QDB_VERSIONS+=("$QDB_CLEAN_VERSION")
    QDB_VERSIONS_DATE+=("`date +"%y-%m-%dT%H:%M:%S"`")
}

# update_release_version: updates QDB_VERSIONS and QDB_VERSIONS_DATE arrays
function update_release_version {
    local version=$1
    for ((index=1; index < (${#QDB_VERSIONS[@]} +1) ; ++index)); do
        if [ "${QDB_VERSIONS[$index]}" == "$version" ]; then
            # somehow we need to change the index of the previous element
            QDB_VERSIONS_DATE[($index-1)]="`date +"%y-%m-%dT%H:%M:%S"`"
        fi
    done
}

# update_version_file: rewrites versions.sh file with current settings
function update_version_file {
    local new_qdb_versions=`join_by " " ${QDB_VERSIONS[@]}`
    sed -i "1,/QDB_VERSIONS=/{s|QDB_VERSIONS=.*).*|QDB_VERSIONS=($new_qdb_versions)|}" `basename "versions.sh"`

    local new_qdb_versions_date=`join_by " " ${QDB_VERSIONS_DATE[@]}`
    sed -i "1,/QDB_VERSIONS_DATE=/{s|QDB_VERSIONS_DATE=.*|QDB_VERSIONS_DATE=($new_qdb_versions_date)|}" `basename "versions.sh"`
}