#!/bin/bash

source "utils.sh"

QDB_VERSION=
QDB_VERSION_PREFIX=
QDB_CLEAN_VERSION=
QDB_DEB_VERSION=1
QDB_LATEST_VERSION=2.7.0
QDB_NIGHTLY_VERSION=
QDB_VERSIONS=()
QDB_MOST_RECENT_VERSIONS=()

# get_versions: Get versions already uploaded to docker
function get_versions {
    container_name=$1
    local docker_tags=(`wget -q https://registry.hub.docker.com/v1/repositories/bureau14/${container_name}/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n' | awk -F: '{print $3}'`)
    for ((index=0; index < (${#docker_tags[@]}) ; ++index)); do
        local version=${docker_tags[$index]}
        if [[ ${version} =~ (^([0-9].[0-9].[0-9])$) ]]; then
            echo "${version}"
            QDB_VERSIONS+=(${version})
        fi
    done
}

# detect_version: Detects qdb version
function detect_version {
    local server_file=`ls qdb-server_*-1.deb`
    if [[ ${server_file} =~ (qdb-server_(.+)-1.deb$) ]]; then
        QDB_VERSION=${BASH_REMATCH[2]}
        if [[ ${QDB_VERSION} =~ (^(([0-9].[0-9]).[0-9]).*) ]]; then
            QDB_CLEAN_VERSION=(${BASH_REMATCH[2]})
            QDB_VERSION_PREFIX=(${BASH_REMATCH[3]})
        fi
        echo "version: $QDB_VERSION"
        echo "clean version: $QDB_CLEAN_VERSION"
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

# add_release_version: in case the detected version is new, update
function add_release_version {
    local detected_version=$QDB_CLEAN_VERSION
    QDB_VERSIONS+=("$detected_version")
}

#create_most_recents_versions: create an array with the most recent versions of each [x.y].z version
#example:
#versions             - 2.0.2, 2.0.3, 2.1.0, 2.2.0, 2.2.1
#most_recent_versions -        2.0.3, 2.1.0       , 2.2.1
function create_most_recents_versions {
    for ((index_i=0; index_i < (${#QDB_VERSIONS[@]}) ; ++index_i)); do
        local success=1
        local version=${QDB_VERSIONS[index_i]}
        if [[ ${version} =~ (^([0-9]).([0-9]).([0-9])$) ]]; then
            local first_part=${BASH_REMATCH[2]}
            local second_part=${BASH_REMATCH[3]}
            local third_part=${BASH_REMATCH[4]}
        fi
        for ((index_j=$index_i+1; index_j < (${#QDB_VERSIONS[@]}) ; ++index_j)); do
            local r_version=${QDB_VERSIONS[index_j]}
            if [[ ${r_version} =~ (^([0-9]).([0-9]).([0-9])$) ]]; then
                local r_first_part=${BASH_REMATCH[2]}
                local r_second_part=${BASH_REMATCH[3]}
                local r_third_part=${BASH_REMATCH[4]}
            fi
            if (( ($first_part == $r_first_part) && ($second_part == $r_second_part) ));then
                if (($third_part < $r_third_part)); then
                    success=0
                fi
            fi
        done
        if (($success == 1));then
            QDB_MOST_RECENT_VERSIONS+=($version)
        fi
    done
}

#is_most_recent_version: test if the current version is in the most recent version array
function is_most_recent_version {
    for most_recent_version in ${QDB_MOST_RECENT_VERSIONS[@]}; do
        if [[ $most_recent_version == $QDB_CLEAN_VERSION ]];then
            return 1
        fi
    done
    return 0
}

#create_nightly_version: create nightly version variable by picking up the highest version the most recents
function create_nightly_version {
    for ((index_i=0; index_i < (${#QDB_MOST_RECENT_VERSIONS[@]}) ; ++index_i)); do
        local success=1
        local version=${QDB_MOST_RECENT_VERSIONS[index_i]}
        if [[ ${version} =~ (^([0-9]).([0-9]).([0-9])$) ]]; then
            local first_part=${BASH_REMATCH[2]}
            local second_part=${BASH_REMATCH[3]}
            local third_part=${BASH_REMATCH[4]}
        fi
        for ((index_j=0; index_j < (${#QDB_MOST_RECENT_VERSIONS[@]}) ; ++index_j)); do
            local r_version=${QDB_MOST_RECENT_VERSIONS[index_j]}
            if [[ ${r_version} =~ (^([0-9]).([0-9]).([0-9])$) ]]; then
                local r_first_part=${BASH_REMATCH[2]}
                local r_second_part=${BASH_REMATCH[3]}
                local r_third_part=${BASH_REMATCH[4]}
            fi
            if ((($first_part < $r_first_part) || ($second_part < $r_second_part) || ($third_part < $r_third_part) ));then
                success=0
            fi
        done
        if (($success == 1));then
            QDB_NIGHTLY_VERSION=$version
        fi
    done
    echo "nightly: $QDB_NIGHTLY_VERSION"
}