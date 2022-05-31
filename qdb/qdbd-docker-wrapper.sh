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

if [[ -z ${QDB_FIREHOSE_ENDPOINT} ]]
then
    QDB_FIREHOSE_ENDPOINT="${IP}:3836"
fi


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

# Usability improvement: first verify we can write to the depot path

if [ ! -w "${QDB_DEPOT_PATH}" ]
then
    echo ""
    echo "**********************************************************************"
    echo "Error: path ${QDB_DEPOT_PATH} is not writable to the current user."
    echo ""
    echo "If you are mounting this path externally, please ensure it's writable "
    echo "for user ${USER} with uid ${UID}"
    echo "**********************************************************************"
    echo ""
    echo "Troubleshooting information (stat output): "
    echo ""
    stat ${QDB_DEPOT_PATH} || true
    exit 1
fi

###
# QuasarDB
###

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

if [[ ! -z ${QDB_REPLICATION} ]]
then
    echo "Enabling QuasarDB replication factor ${QDB_REPLICATION}"
    patch_conf ".global.cluster.replication_factor" "${QDB_REPLICATION}"
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

if [[ ! -z ${QDB_TOTAL_SERVER_SESSIONS} ]]
then
    echo "Setting total server sessions to ${QDB_TOTAL_SERVER_SESSIONS}"
    patch_conf ".local.network.total_server_sessions" "${QDB_TOTAL_SERVER_SESSIONS}"
fi

if [[ ! -z ${QDB_PARALLELISM} ]]
then
    echo "Setting server parallelism ${QDB_PARALLELISM}"
    patch_conf ".local.network.parallelism" "${QDB_PARALLELISM}"
fi

if [[ ! -z ${QDB_PUBLISH_FIREHOSE} ]]
then
    echo "Enabling firehose"
    patch_conf ".global.cluster.publish_firehose" "true"
fi

if [[ ! -z ${QDB_FIREHOSE_ENDPOINT} ]]
then
    echo "Setting firehose endpoint to \"${QDB_FIREHOSE_ENDPOINT}\""
    patch_conf ".local.network.firehose_endpoint" "\"${QDB_FIREHOSE_ENDPOINT}\""
fi

if [[ ! -z ${QDB_FIREHOSE_PUBLISHING_THREADS} ]]
then
    echo "Setting firehose publishing threads to \"${QDB_FIREHOSE_PUBLISHING_THREADS}\""
    patch_conf ".local.network.firehose_publishing_threads" "\"${QDB_FIREHOSE_PUBLISHING_THREADS}\""
fi

###
# Logging
###
if [[ ! -z ${QDB_LOG_LEVEL} ]]
then
    echo "Setting log level ${QDB_LOG_LEVEL}"
    patch_conf ".local.logger.log_level" "${QDB_LOG_LEVEL}"
fi

if [[ ! -z ${QDB_LOG_PATH} ]]
then
    echo "Setting log path to ${QDB_LOG_PATH}"
    patch_conf ".local.logger.log_directory" "\"${QDB_LOG_PATH}\""
fi

###
# Rocksdb
###

if [[ ! -z ${QDB_DEPOT_PATH} ]]
then
    echo "Setting rocksdb depot path to '${QDB_DEPOT_PATH}'"
    patch_conf ".local.depot.rocksdb.root" "\"${QDB_DEPOT_PATH}\""
fi

if [[ ! -z ${QDB_ROCKSDB_TABLE_MEMORY_BUDGET} ]]
then
    echo "Setting table memory budget to ${QDB_ROCKSDB_TABLE_MEMORY_BUDGET} bytes"
    patch_conf ".local.depot.rocksdb.table_memory_budget" "${QDB_ROCKSDB_TABLE_MEMORY_BUDGET}"
fi

if [[ ! -z ${QDB_ROCKSDB_COLUMN_FAMILY_OPTIONS} ]]
then
    echo "Setting rocksdb column family options to '${QDB_ROCKSDB_COLUMN_FAMILY_OPTIONS}'"
    patch_conf ".local.depot.rocksdb.column_family_options" "\"${QDB_ROCKSDB_COLUMN_FAMILY_OPTIONS}\""
fi

if [[ ! -z ${QDB_ROCKSDB_SST_PARTITIONER_THRESHOLD} ]]
then
    echo "Setting rocksdb SST partitioner threshold to ${QDB_ROCKSDB_SST_PARTITIONER_THRESHOLD}"
    patch_conf ".local.depot.rocksdb.sst_partitionner_threshold" "${QDB_ROCKSDB_SST_PARTITIONER_THRESHOLD}"
fi

if [[ ! -z ${QDB_ROCKSDB_THREADS} ]]
then
    echo "Setting rocksdb regular (compaction) threads to ${QDB_ROCKSDB_THREADS}"
    patch_conf ".local.depot.rocksdb.threads" "${QDB_ROCKSDB_THREADS}"
fi

if [[ ! -z ${QDB_ROCKSDB_HI_THREADS} ]]
then
    echo "Setting rocksdb hi (flush) threads to ${QDB_ROCKSDB_HI_THREADS}"
    patch_conf ".local.depot.rocksdb.hi_threads" "${QDB_ROCKSDB_HI_THREADS}"
fi

###
# Rocksdb cloud
###
#
# Identity / provider / location configurations
#
###

if [[ ! -z ${QDB_CLOUD_PROVIDER} ]]
then
    echo "Setting cloud provider ${QDB_CLOUD_PROVIDER}"
    patch_conf ".local.depot.rocksdb.cloud.provider" "\"${QDB_CLOUD_PROVIDER}\""
fi

if [ "${QDB_CLOUD_AWS_ENABLE_INSTANCE_AUTH}" = "true" ]
then
    echo "Enabling instance-based credential discovery"
    patch_conf ".local.depot.rocksdb.cloud.aws.use_instance_auth" "true"
else
    patch_conf ".local.depot.rocksdb.cloud.aws.use_instance_auth" "false"

    # Not secret
    if [[ ! -z ${QDB_CLOUD_AWS_ACCESS_KEY_ID} ]]
    then
        echo "Setting cloud aws access key id to ${QDB_CLOUD_AWS_ACCESS_KEY_ID}"
        patch_conf ".local.depot.rocksdb.cloud.aws.access_key_id" "\"${QDB_CLOUD_AWS_ACCESS_KEY_ID}\""
    fi

    # SECRET, DO *NOT* LOG!
    if [[ ! -z ${QDB_CLOUD_AWS_SECRET_ACCESS_KEY} ]]
    then
        echo "Setting cloud aws secret access key. "
        echo ""
        echo "**********************************************************************"
        echo "Warning: secrets as environment variables is considered insecure. "
        echo "We recommend using instance-based authentication."
        echo "**********************************************************************"
        echo ""
        patch_conf ".local.depot.rocksdb.cloud.aws.secret_key" "\"${QDB_CLOUD_AWS_SECRET_ACCESS_KEY}\""
    fi
fi

if [[ ! -z ${QDB_CLOUD_BUCKET_REGION} ]]
then
    echo "Setting s3 bucket region to ${QDB_CLOUD_BUCKET_REGION}"
    patch_conf ".local.depot.rocksdb.cloud.bucket.region" "\"${QDB_CLOUD_BUCKET_REGION}\""
fi

if [[ ! -z ${QDB_CLOUD_BUCKET_PREFIX} ]]
then
    echo "Setting s3 bucket prefix to ${QDB_CLOUD_BUCKET_PREFIX}"
    patch_conf ".local.depot.rocksdb.cloud.bucket.source_prefix" "\"${QDB_CLOUD_BUCKET_PREFIX}\""
    patch_conf ".local.depot.rocksdb.cloud.bucket.destination_prefix" "\"${QDB_CLOUD_BUCKET_PREFIX}\""
fi

if [[ ! -z ${QDB_CLOUD_BUCKET_SUFFIX} ]]
then
    echo "Setting s3 bucket suffix to ${QDB_CLOUD_BUCKET_SUFFIX}"
    patch_conf ".local.depot.rocksdb.cloud.bucket.source_suffix" "\"${QDB_CLOUD_BUCKET_SUFFIX}\""
    patch_conf ".local.depot.rocksdb.cloud.bucket.destination_suffix" "\"${QDB_CLOUD_BUCKET_SUFFIX}\""
fi

if [[ ! -z ${QDB_CLOUD_BUCKET_PATH_PREFIX} ]]
then
    echo "Setting s3 bucket path to ${QDB_CLOUD_BUCKET_PATH_PREFIX}"
    patch_conf ".local.depot.rocksdb.cloud.bucket.path_prefix" "\"${QDB_CLOUD_BUCKET_PATH_PREFIX}\""
fi

###
# Rocksdb cloud
###
#
# Performance-related configurations
#
###

if [[ ! -z ${QDB_CLOUD_LOCAL_SST_CACHE} ]]
then
    echo "Setting cloud local cache to ${QDB_CLOUD_LOCAL_SST_CACHE} bytes"
    patch_conf ".local.depot.rocksdb.cloud.local_sst_cache_size" "${QDB_CLOUD_LOCAL_SST_CACHE_SIZE}"
fi

if [[ ! -z ${QDB_CLOUD_AWS_TRANSFER_MANAGER_THREADS} ]]
then
    echo "Setting AWS transfer manager thread count to ${QDB_CLOUD_AWS_TRANSFER_MANAGER_THREADS}"
    patch_conf ".local.depot.rocksdb.cloud.aws.use_transfer_manager" "true"
    patch_conf ".local.depot.rocksdb.cloud.aws.transfer_manager_threads" "${QDB_CLOUD_AWS_TRANSFER_MANAGER_THREADS}"
fi

if [[ ! -z ${QDB_CLOUD_AWS_TRANSFER_MANAGER_BUFFER_SIZE} ]]
then
    echo "Setting AWS transfer manager buffer size to ${QDB_CLOUD_AWS_TRANSFER_MANAGER_BUFFER_SIZE}"
    patch_conf ".local.depot.rocksdb.cloud.aws.use_transfer_manager" "true"
    patch_conf ".local.depot.rocksdb.cloud.aws.transfer_manager_buffer_size" "${QDB_CLOUD_AWS_TRANSFER_MANAGER_BUFFER_SIZE}"
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
