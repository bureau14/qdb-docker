FROM       ubuntu:bionic

RUN        groupadd -r qdb && useradd -r -g qdb qdb

ARG        QDB_DEB_VERSION=1

ENV        QDB_PORT=2836
ENV        QDB_ENABLE_SECURITY="false"
ENV        QDB_CONFIG_PATH="/opt/qdb/etc/qdbd.conf"
ENV        QDB_CLUSTER_PRIVATE_KEY=""
ENV        QDB_CLUSTER_PRIVATE_KEY_FILE=""
ENV        QDB_USER_LIST=""
ENV        QDB_USER_LIST_FILE=""
ENV        QDB_LICENSE=""
ENV        QDB_LICENSE_FILE=""
ENV        QDB_REPLICATION=""
ENV        QDB_MEMORY_LIMIT_SOFT=""
ENV        QDB_MEMORY_LIMIT_HARD=""

# Fixing debconf warning about TERM
ENV        DEBIAN_FRONTEND teletype

# Latest Ubuntu doesn't have pre-installed locales package (locale-gen) and 'ip' from iproute
# apt-utils also fix warnings from debconfig
RUN        apt-get clean \
        && apt-get update \
        && apt-get install -y --no-install-recommends apt-utils iproute2 jq less locales net-tools dnsutils telnet wget
RUN        locale-gen en_US.UTF-8

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

# Add default qdbd.conf
ADD        qdbd.conf /opt/qdb/etc/

RUN        mkdir /opt/qdb/db
RUN        chown -R qdb:qdb /opt/qdb
USER       qdb
