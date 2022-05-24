FROM       docker.io/ubuntu:22.04

RUN        apt-get update && \
           apt-get upgrade -y  && \
           apt-get install -y \
                           --no-install-recommends \
                           apt-utils \
                           dnsutils \
                           iproute2 \
                           jq \
                           less \
                           locales \
                           net-tools \
                           telnet \
                           wget && \
           apt-get clean && \
           rm -rf /var/lib/apt/lists/*

# Fixing debconf warning about TERM
ENV        DEBIAN_FRONTEND="teletype"

RUN        locale-gen en_US.UTF-8
RUN        groupadd -r qdb && useradd -r -g qdb qdb

# Quasardb
ENV        QDB_PORT=2836
ENV        QDB_LOG_LEVEL=1
ENV        QDB_LOG_PATH="/opt/qdb/log"
ENV        QDB_ADVERTISED_ADDRESS=""
ENV        QDB_ENABLE_SECURITY="false"
ENV        QDB_CONFIG_PATH="/opt/qdb/etc/qdbd.conf"
ENV        QDB_DEPOT_PATH="/depot"
ENV        QDB_CLUSTER_PRIVATE_KEY=""
ENV        QDB_CLUSTER_PRIVATE_KEY_FILE=""
ENV        QDB_USER_LIST=""
ENV        QDB_USER_LIST_FILE=""
ENV        QDB_LICENSE=""
ENV        QDB_LICENSE_FILE=""
ENV        QDB_REPLICATION=""
ENV        QDB_TOTAL_SERVER_SESSIONS=""
ENV        QDB_PARALLELISM=""
ENV        QDB_FIREHOSE_ENDPOINT=""
ENV        QDB_FIREHOSE_PUBLISHING_THREADS=""
ENV        QDB_MEMORY_LIMIT_SOFT=""
ENV        QDB_MEMORY_LIMIT_HARD=""
ENV        QDB_COLUMN_FAMILY_OPTIONS=""
ENV        QDB_SST_PARTITIONER_THRESHOLD=""


# Rocksdb
ENV        QDB_ROCKSDB_COLUMN_FAMILY_OPTIONS=""
ENV        QDB_ROCKSDB_SST_PARTITIONER_THRESHOLD=""
ENV        QDB_ROCKSDB_THREADS=""
ENV        QDB_ROCKSDB_HI_THREADS=""

###
# Rocksdb cloud
###
#
# Identity / provider / location configurations
#
###
ENV        QDB_CLOUD_PROVIDER=""
ENV        QDB_CLOUD_BUCKET_REGION=""
ENV        QDB_CLOUD_BUCKET_PREFIX=""
ENV        QDB_CLOUD_BUCKET_SUFFIX=""
ENV        QDB_CLOUD_BUCKET_PATH_PREFIX="qdb-docker"

ENV        QDB_CLOUD_AWS_ENABLE_INSTANCE_AUTH="true"
ENV        QDB_CLOUD_AWS_ACCESS_KEY_ID=""
ENV        QDB_CLOUD_AWS_SECRET_ACCESS_KEY=""

###
# Rocksdb cloud
###
#
# Performance-related configurations
#
###
ENV        QDB_CLOUD_LOCAL_SST_CACHE=""


# Install qdb-server package
ADD        qdb-*-linux-64bit-server.tar.gz /opt/qdb/

# Add the wrapper script
ADD        qdbd-docker-wrapper.sh /opt/qdb/scripts/

# Define working directory
WORKDIR    /opt/qdb

# Always launch qdb process
ENTRYPOINT ["/opt/qdb/scripts/qdbd-docker-wrapper.sh"]

# Expose the port qdbd is listening at
EXPOSE     2836
EXPOSE     2837
EXPOSE     3836

# Add default qdbd.conf
ADD        qdbd.conf /opt/qdb/etc/

RUN        mkdir /depot
RUN        chown -R qdb:qdb /opt/qdb
RUN        chown -R qdb:qdb /depot
USER       qdb
