#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
ARG        BASE
FROM       ${BASE}

##########################################################
#
# Configuration variable declaration + default definitions
#
##########################################################

###
# Quasardb core
#
ENV        QDB_LICENSE=""
ENV        QDB_LICENSE_FILE=""
ENV        QDB_PORT=2836
ENV        QDB_BIND_ADDRESS=""
ENV        QDB_ADVERTISED_ADDRESS=""
ENV        QDB_LOG_LEVEL=1
ENV        QDB_LOG_PATH="/opt/qdb/log"
ENV        QDB_DEPOT_PATH="/opt/qdb/depot"
ENV        QDB_CONFIG_PATH="/opt/qdb/etc/qdbd.conf"
ENV        QDB_ENABLE_SECURITY="false"
ENV        QDB_CLUSTER_PRIVATE_KEY=""
ENV        QDB_CLUSTER_PRIVATE_KEY_FILE=""
ENV        QDB_USER_LIST=""
ENV        QDB_USER_LIST_FILE=""
ENV        QDB_REPLICATION=""
ENV        QDB_TOTAL_SERVER_SESSIONS=""
ENV        QDB_PARALLELISM=""
ENV        QDB_PUBLISH_FIREHOSE=""
ENV        QDB_FIREHOSE_PORT=""
ENV        QDB_FIREHOSE_PUBLISHING_THREADS=""
ENV        QDB_MEMORY_LIMIT_SOFT=""
ENV        QDB_MEMORY_LIMIT_HARD=""

###
# Rocksdb
#
ENV        QDB_ROCKSDB_COLUMN_FAMILY_OPTIONS=""
ENV        QDB_ROCKSDB_SST_PARTITIONER_THRESHOLD=""
ENV        QDB_ROCKSDB_THREADS=""
ENV        QDB_ROCKSDB_HI_THREADS=""
ENV        QDB_ROCKSDB_TABLE_MEMORY_BUDGET=""

###
# Rocksdb cloud
##
# Identity / provider / location configurations
#
ENV        QDB_CLOUD_PROVIDER=""
ENV        QDB_CLOUD_BUCKET_REGION=""
ENV        QDB_CLOUD_BUCKET=""
ENV        QDB_CLOUD_BUCKET_PATH_PREFIX="qdb-docker"

ENV        QDB_CLOUD_AWS_ENABLE_INSTANCE_AUTH="true"
ENV        QDB_CLOUD_AWS_ACCESS_KEY_ID=""
ENV        QDB_CLOUD_AWS_SECRET_ACCESS_KEY=""
ENV        QDB_CLOUD_AWS_TRANSFER_MANAGER_THREADS=""
ENV        QDB_CLOUD_AWS_TRANSFER_MANAGER_BUFFER_SIZE=""

###
# Rocksdb cloud
##
#
# Performance-related configurations
#
ENV        QDB_CLOUD_LOCAL_SST_CACHE=""

###
# Kubernetes
##
ENV        K8S_REPLICA_COUNT=""

ADD --chown=${QDB_USER}:${QDB_GROUP} https://download.quasar.ai/quasardb/3.13/3.13.7/server/qdb-3.13.7-linux-64bit-aarch64-server.tar.gz /opt/qdb/
ADD --chown=${QDB_USER}:${QDB_GROUP} qdbd-docker-wrapper.sh   /opt/qdb/scripts/
ADD --chown=${QDB_USER}:${QDB_GROUP} qdbd.conf                /opt/qdb/etc/

RUN    cd /opt/qdb                 \
    && tar -xzf ./*.tar.gz            \
    && rm -f ./*.tar.gz               \
                                      \
    && mkdir -p ${QDB_DEPOT_PATH}     \
    && mkdir -p ${QDB_LOG_PATH}       \
                                      \
    && /opt/qdb/bin/qdbd --version


# required: normal port - high-traffic
EXPOSE     2836

# required: control     - low-traffic, important
EXPOSE     2837

# optional: continuous queries
EXPOSE     3836

ENTRYPOINT ["/opt/qdb/scripts/qdbd-docker-wrapper.sh"]
