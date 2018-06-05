FROM       ubuntu:xenial

ARG        QDB_VERSION=
ENV        QDB_DEB_VERSION=1

# Fixing debconf warning about TREM
ENV        DEBIAN_FRONTEND teletype

# Latest Ubuntu doesn't have pre-installed locales package (locale-gen) and 'ip' from iproute
# apt-utils also fix warnings from debconfig
RUN        apt-get clean && apt-get update && apt-get install -y --no-install-recommends apt-utils locales iproute
RUN        locale-gen en_US.UTF-8

# Install qdb-server package
COPY    qdb-utils_${QDB_VERSION}-${QDB_DEB_VERSION}.deb .
RUN     dpkg -i qdb-utils_${QDB_VERSION}-${QDB_DEB_VERSION}.deb \
        && rm qdb-utils_${QDB_VERSION}-${QDB_DEB_VERSION}.deb

# Always launch qdb process
ENTRYPOINT ["qdbsh"]
