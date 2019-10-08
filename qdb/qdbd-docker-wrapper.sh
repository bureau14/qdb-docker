#!/usr/bin/env bash

set -e

QDB_CONFIG="/tmp/qdbd.conf"
cp -v ${QDB_CONFIG_PATH} ${QDB_CONFIG}

QDB_SERVER="/opt/qdb/bin/qdbd"
QDB_LAUNCH_ARGS=""
IP=`which ip`
AWK=`which awk`
MKTEMP=`which mktemp`
JQ=`which jq`

IP=`${IP} route get 8.8.8.8 | grep -oh 'src [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | awk '{print $2}'`

echo "Launching qdbd bound to ${IP}:2836"
QDB_LAUNCH_ARGS="${QDB_LAUNCH_ARGS} -a ${IP}:2836"

function die {
    echo "" >> /dev/stderr
    echo "******************"  >> /dev/stderr
    echo $1 >> /dev/stderr
    echo "******************"  >> /dev/stderr
    exit 1
}

function patch_conf {
    KEY=$1
    VALUE=$2

    F=$(${MKTEMP})
    cat ${QDB_CONFIG} | ${JQ} -r "${KEY} |= ${VALUE}" > ${F}
    mv ${F} ${QDB_CONFIG}
}

function file_or_string {
    MAYBE_STRING=$1
    MAYBE_FILE=$2

    F=$(${MKTEMP})

    if [[ ! -z ${!MAYBE_STRING} ]]
    then
        echo ${!MAYBE_STRING} > ${F}
    elif [[ ! -z ${!MAYBE_FILE} ]]
    then
        F=${!MAYBE_FILE}
    else
        die "Neither ${MAYBE_STRING} nor ${MAYBE_FILE} is set!"
    fi

    echo ${F}
}

if [ "${QDB_ENABLE_SECURITY}" = "true" ]
then
    echo "Enabling security"
    PRIVKEY=$(file_or_string "QDB_CLUSTER_PRIVATE_KEY" "QDB_CLUSTER_PRIVATE_KEY_FILE")
    ULIST=$(file_or_string "QDB_USER_LIST" "QDB_USER_LIST_FILE")

    patch_conf ".global.security.enabled" "true"
    patch_conf ".global.security.encrypt_traffic" "true"
    patch_conf ".global.security.cluster_private_file" "\"${PRIVKEY}\""
    patch_conf ".global.security.user_list" "\"${ULIST}\""
fi

if [[ ! -z ${QDB_LICENSE} ]]
then
    echo "Enabling license"
    patch_conf ".local.user.license_key" "\"${QDB_LICENSE}\""
elif [[ ! -z ${QDB_LICENSE_FILE} ]]
then
    echo "Enabling license file: ${QDB_LICENSE_FILE}"
    patch_conf ".local.user.license_file" "\"${QDB_LICENSE_FILE}\""
fi

echo "Launching qdb with arguments: ${QDB_LAUNCH_ARGS}"

${QDB_SERVER} --config ${QDB_CONFIG} ${QDB_LAUNCH_ARGS} $@
