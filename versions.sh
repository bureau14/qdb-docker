#!/bin/bash

source "utils.sh"

QDB_VERSION= # full version name, ex: 3.2.0master
QDB_CLEAN_VERSION= # version name without suffix, ex: 3.2.0
QDB_SHORT_VERSION= # short version name without suffix, ex: 3.2
QDB_LATEST_VERSION=3.1.0
QDB_NIGHTLY_VERSION=3.2.0

# detect_version: Detects qdb version
function detect_version {
    local server_file=`ls qdb-*-server.tar.gz`
    if [[ ${server_file} =~ (qdb-(.+)-linux-64bit-server.tar.gz$) ]]; then
        QDB_VERSION=${BASH_REMATCH[2]}
        if [[ ${QDB_VERSION} =~ (^(([0-9].[0-9]).[0-9]).*) ]]; then
            QDB_CLEAN_VERSION=(${BASH_REMATCH[2]})
            QDB_SHORT_VERSION=(${BASH_REMATCH[3]})
        fi
        echo "version: $QDB_VERSION"
        echo "clean version: $QDB_CLEAN_VERSION"
        return 0
    else
        echo "version not found, aborting..."
        return 1
    fi
}
<<<<<<< HEAD
=======

# -- commented out by @leon on 2019/01/15 because we do not build the 'dev-tools'
#    docker container anymore.
#
# normalize_versions: Changes names for php tarball and python egg to match the other files
# function normalize_versions {
#     local php_tar=`ls quasardb-*.tgz`
#     if [[ $php_tar != "quasardb-${QDB_VERSION}.tgz" ]];then
#         mv $php_tar quasardb-${QDB_VERSION}.tgz
#     fi
#     local python_egg=`ls quasardb-*-py2.7-linux-x86_64.egg`
#     if [[ $python_egg != "quasardb-${QDB_VERSION}-py2.7-linux-x86_64.egg" ]];then
#         mv $python_egg quasardb-${QDB_VERSION}-py2.7-linux-x86_64.egg
#     fi
# }

# check_released_versions: check if detected version matches an already released version
function check_released_versions {
    for version in ${QDB_VERSIONS[@]}; do
        if [ "$QDB_CLEAN_VERSION" == "$version" ]; then
            return 0
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
    for ((index_i=0; index_i < (${#QDB_VERSIONS[@]}) ; ++index_i))
    do
        local success=0
        local version=${QDB_VERSIONS[index_i]}
        if [[ ${version} =~ (^([0-9]).([0-9]).([0-9])$) ]]
        then
            local first_part=${BASH_REMATCH[2]}
            local second_part=${BASH_REMATCH[3]}
            local third_part=${BASH_REMATCH[4]}
        fi
        for ((index_j=$index_i+1; index_j < (${#QDB_VERSIONS[@]}) ; ++index_j))
        do
            local r_version=${QDB_VERSIONS[index_j]}
            if [[ ${r_version} =~ (^([0-9]).([0-9]).([0-9])$) ]]
            then
                local r_first_part=${BASH_REMATCH[2]}
                local r_second_part=${BASH_REMATCH[3]}
                local r_third_part=${BASH_REMATCH[4]}
            fi
            if (( ($first_part == $r_first_part) && ($second_part == $r_second_part) ))
            then
                if (($third_part < $r_third_part))
                then
                    success=1
                fi
            fi
        done

        if (($success == 0))
        then
            QDB_MOST_RECENT_VERSIONS+=($version)
        fi
    done
}

#is_most_recent_version: test if the current version is in the most recent version array
function is_most_recent_version {
    for most_recent_version in ${QDB_MOST_RECENT_VERSIONS[@]}
    do
        if [[ $most_recent_version == $QDB_CLEAN_VERSION ]]
        then
            echo "${QDB_CLEAN_VERSION}"
        fi
    done
}

#create_nightly_version: create nightly version variable by picking up the highest version the most recents
function create_nightly_version {
    for ((index_i=0; index_i < (${#QDB_MOST_RECENT_VERSIONS[@]}) ; ++index_i))
    do
        local success=0
        local version=${QDB_MOST_RECENT_VERSIONS[index_i]}

        echo "version = ${version}"

        if [[ ${version} =~ (^([0-9]).([0-9]).([0-9])$) ]]
        then
            local first_part=${BASH_REMATCH[2]}
            local second_part=${BASH_REMATCH[3]}
            local third_part=${BASH_REMATCH[4]}
        fi
        for ((index_j=0; index_j < (${#QDB_MOST_RECENT_VERSIONS[@]}) ; ++index_j))
        do
            local r_version=${QDB_MOST_RECENT_VERSIONS[index_j]}
            if [[ ${r_version} =~ (^([0-9]).([0-9]).([0-9])$) ]]
            then
                local r_first_part=${BASH_REMATCH[2]}
                local r_second_part=${BASH_REMATCH[3]}
                local r_third_part=${BASH_REMATCH[4]}
            fi

            echo "first part $r_first_part"
            echo "second part $r_second_part"
            echo "third part $r_third_part"

            if ((($first_part < $r_first_part) || ($second_part < $r_second_part) || ($third_part < $r_third_part) ))
            then
                success=1
            fi
        done

        if (($success == 0))
        then
            QDB_NIGHTLY_VERSION=3.2.0
        fi
    done
    echo "nightly: $QDB_NIGHTLY_VERSION"
}
>>>>>>> master
