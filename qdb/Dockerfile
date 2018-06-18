FROM       ubuntu:xenial

ARG        QDB_VERSION=
ARG        QDB_DEB_VERSION=1

ENV        QDB_PORT=2836

# Fixing debconf warning about TERM
ENV        DEBIAN_FRONTEND teletype

# Latest Ubuntu doesn't have pre-installed locales package (locale-gen) and 'ip' from iproute
# apt-utils also fix warnings from debconfig
RUN        apt-get clean && apt-get update && apt-get install -y --no-install-recommends apt-utils locales iproute
RUN        locale-gen en_US.UTF-8

# Install qdb-server package
COPY    qdb-server_${QDB_VERSION}-${QDB_DEB_VERSION}.deb .
RUN     dpkg -i qdb-server_${QDB_VERSION}-${QDB_DEB_VERSION}.deb

# Add the wrapper script
ADD        qdbd-docker-wrapper.sh /usr/bin/

# Define mountable directory
VOLUME     ["/var/lib/qdb"]

# Define working directory
WORKDIR    /var/lib/qdb

# Always launch qdb process
ENTRYPOINT ["/usr/bin/qdbd-docker-wrapper.sh"]

# Expose the port qdbd is listening at
EXPOSE     2836
