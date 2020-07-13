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

function die {
    >&2 echo $1
    exit 1
}

function host_to_ip {
    # QuasarDB does not support bootstrapping with hostnames, only IPs. This function
    # translates hostnames to ips.
    IP=$(getent hosts $1 | awk '{ print $1 }')
    if [[ "${IP}" == "" ]]
    then
        die "FATAL: Unable to resolve host name of peer: $1"
    fi

    echo ${IP}
}

function bootstrap_peers {
    DOMAIN=$1
    HOSTNAME=$2
    THIS_REPLICA=$3

    # Our strategy for bootstrapping is to just add all the nodes 'before' the current
    # one, i.e. node quasardb-2 connects to quasardb-1 and quasardb-0.

    RET="["
    for ((i=(${THIS_REPLICA} - 1); i>=0; i--))
    do
        if [[ ! "${RET}" == "[" ]]
        then
            RET="${RET}, "
        fi

        THIS_HOST="${HOSTNAME}-${i}.${DOMAIN}"
        THIS_IP=$(host_to_ip ${THIS_HOST})
        RET="${RET}\"${THIS_IP}:2836\""
    done
    RET="${RET}]"

    echo ${RET}
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
if [[ ! -z ${QDB_ADVERTISED_ADDRESS} ]]
then
    echo "Setting advertised address"
    QDB_LAUNCH_ARGS="${QDB_LAUNCH_ARGS} --advertised-address ${QDB_ADVERTISED_ADDRESS}"
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


if [[ ! -z ${QDB_REPLICATION} ]]
then
    echo "Enabling QuasarDB replication factor ${QDB_REPLICATION}"
    patch_conf ".global.cluster.replication_factor" "${QDB_REPLICATION}"
fi

if [[ ! -z ${QDB_MEMORY_LIMIT_SOFT} ]]
then
    echo "Setting soft memory limit to ${QDB_MEMORY_LIMIT_SOFT}"
    patch_conf ".local.limiter.max_bytes_soft" "${QDB_MEMORY_LIMIT_SOFT}"
fi

if [[ ! -z ${QDB_MEMORY_LIMIT_HARD} ]]
then
    echo "Setting hard memory limit to ${QDB_MEMORY_LIMIT_HARD}"
    patch_conf ".local.limiter.max_bytes_hard" "${QDB_MEMORY_LIMIT_HARD}"
fi


if [[ ! -z ${K8S_REPLICA_COUNT} ]]
then
    # Logic below inspired by official kubernetes Zookeeper image:
    #
    #  https://github.com/kow3ns/kubernetes-zookeeper/blob/master/docker/scripts/start-zookeeper
    #
    # Essentially, per StatefulSet documentation, we assume we operate in a StatefulSet, and
    # can rely on the other node hostnames following a certain pattern. We seed all the bootstrap
    # peers for all previous nodes.
    #
    # Example: if our current hostname is `quasardb-2`, the bootstrap peers will become
    # ["quasardb-1:2836", "quasardb-0:2836"].
    #
    # This also implies that node quasardb-0 will not have any bootstrapping peers, which is
    # exactly the behavior we want in the case of QuasarDB.
    HOST=$(hostname -s)
    DOMAIN=$(hostname -d)

    echo "Host = ${HOST}, Domain = ${DOMAIN}"

    if [[ $HOST =~ (.*)-([0-9]+)$ ]]
    then
        NAME=${BASH_REMATCH[1]}
        ORD=${BASH_REMATCH[2]}
        NODE_OFFSET=$((ORD + 1))
        NODE_ID="${NODE_OFFSET}/${K8S_REPLICA_COUNT}"

        echo "Setting node id to ${NODE_ID}"
        patch_conf ".local.chord.node_id" "\"${NODE_ID}\""

        BOOTSTRAP_PEERS=$(bootstrap_peers ${DOMAIN} ${NAME} ${ORD})

        echo "Setting bootstrap peers to ${BOOTSTRAP_PEERS}"
        patch_conf ".local.chord.bootstrapping_peers" "${BOOTSTRAP_PEERS}"

    else
        echo "Failed to parse name and ordinal of Pod: ${HOST}"
        exit 1
    fi
fi

echo "Launching qdb with arguments: ${QDB_LAUNCH_ARGS}"

exec ${QDB_SERVER} --config ${QDB_CONFIG} ${QDB_LAUNCH_ARGS} $@
