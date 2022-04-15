FROM       ubuntu:22.04 AS build

# Use separate build layer to easily extract only qdbsh from the utils tarball
ADD        qdb-*-linux-64bit-utils.tar.gz /opt/qdb/

FROM        ubuntu:22.04

# Fixing debconf warning about TERM
ENV        DEBIAN_FRONTEND teletype

RUN        apt-get update && \
           apt-get upgrade -y && \
           apt-get install -y --no-install-recommends locales && \
           locale-gen en_US.UTF-8 && \
           apt-get remove -y locales && \
           apt-get clean && \
           rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/qdb/bin/qdbsh  /opt/qdb/bin/qdbsh

# Always launch qdb process
ENTRYPOINT ["/opt/qdb/bin/qdbsh"]
