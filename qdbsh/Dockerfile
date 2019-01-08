FROM       ubuntu:xenial

ARG        QDB_VERSION=

# Fixing debconf warning about TREM
ENV        DEBIAN_FRONTEND teletype

# Latest Ubuntu doesn't have pre-installed locales package (locale-gen) and 'ip' from iproute
# apt-utils also fix warnings from debconfig
RUN        apt-get clean && apt-get update && apt-get install -y --no-install-recommends apt-utils locales iproute
RUN        locale-gen en_US.UTF-8

# Install qdb-server package
ADD     qdb-${QDB_VERSION}-linux-64bit-utils.tar.gz /opt/qdb/
ADD     qdb-${QDB_VERSION}-linux-64bit-c-api.tar.gz /opt/qdb/

# Always launch qdb process
ENTRYPOINT ["/opt/qdb/bin/qdbsh"]
