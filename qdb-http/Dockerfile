FROM       ubuntu:xenial

ARG        QDB_VERSION=
ENV        QDB_DEB_VERSION=1

# Fixing debconf warning about TERM
ENV        DEBIAN_FRONTEND teletype

# Latest Ubuntu doesn't have pre-installed locales package (locale-gen) and 'ip' from iproute
# apt-utils also fix warnings from debconfig
RUN        apt-get clean && apt-get update && apt-get install -y --no-install-recommends apt-utils locales iproute
RUN        locale-gen en_US.UTF-8

# Install qdb-web-bridge package
COPY    qdb-web-bridge_${QDB_VERSION}-${QDB_DEB_VERSION}.deb .
RUN     dpkg -i qdb-web-bridge_${QDB_VERSION}-${QDB_DEB_VERSION}.deb

# Add the wrapper script
ADD        qdb-httpd-docker-wrapper.sh /usr/bin/

# Always launch qdb process
ENTRYPOINT ["/usr/bin/qdb-httpd-docker-wrapper.sh"]

# Expose the port qdb-httpd is listening at
EXPOSE     8080
