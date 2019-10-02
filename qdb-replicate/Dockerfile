FROM ubuntu:bionic

# Fixing debconf warning about TERM
ENV DEBIAN_FRONTEND teletype

# Latest Ubuntu doesn't have pre-installed locales package (locale-gen) and 'ip' from iproute
# apt-utils also fix warnings from debconfig
RUN apt-get update && apt-get install -y --no-install-recommends locales &&  apt-get clean
RUN locale-gen en_US.UTF-8

# Install packages
ADD qdb-*-linux-64bit-utils.tar.gz /opt/qdb/

# Always launch qdb process
ENTRYPOINT ["/opt/qdb/bin/qdb_replicate"]
