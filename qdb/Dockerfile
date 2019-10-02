FROM       ubuntu:bionic

ARG        QDB_DEB_VERSION=1

ENV        QDB_PORT=2836
ENV        QDB_DISABLE_SECURITY="true"

# Fixing debconf warning about TERM
ENV        DEBIAN_FRONTEND teletype

# Latest Ubuntu doesn't have pre-installed locales package (locale-gen) and 'ip' from iproute
# apt-utils also fix warnings from debconfig
RUN        apt-get clean \
        && apt-get update \
        && apt-get install -y --no-install-recommends apt-utils iproute2 jq less locales net-tools wget
RUN        locale-gen en_US.UTF-8

# Install qdb-server package
ADD     qdb-*-linux-64bit-server.tar.gz /opt/qdb/

# Add the wrapper script
ADD        qdbd-docker-wrapper.sh /opt/qdb/scripts/

# Define mountable directory
VOLUME     ["/var/lib/qdb"]

# Define working directory
WORKDIR    /var/lib/qdb

# Always launch qdb process
ENTRYPOINT ["/opt/qdb/scripts/qdbd-docker-wrapper.sh"]

# Expose the port qdbd is listening at
EXPOSE     2836

# Add default qdbd.conf
ADD        qdbd.conf /opt/qdb/etc/
