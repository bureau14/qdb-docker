FROM ubuntu:xenial

COPY qdb-api*.deb .
COPY qdb-rest*.deb .
COPY qdb-dashboard*.deb .

RUN apt-get update && \
    apt-get install -y iproute \
                       jq \
                       locales \
                       nano \
                       net-tools \
                       openssl \
                       wget && \
    apt-get clean

RUN dpkg -i qdb-api*.deb
RUN dpkg -i qdb-rest*.deb
RUN dpkg -i qdb-dashboard*.deb

RUN cat /etc/qdb/qdb_rest.conf \
    | jq ".allowed_origins = [\"http://0.0.0.0:3449\"]" \
    | jq ".assets = \"/var/lib/qdb/assets\"" \
    | jq ".cluster_uri = \"qdb://qdb-server:2836\"" \
    | jq ".tls_host = \"0.0.0.0\"" \
    > /tmp/qdb_rest.conf.new && \
    mv /tmp/qdb_rest.conf.new /etc/qdb/qdb_rest.conf && \
    chown qdb:qdb /etc/qdb/qdb_rest.conf

ENTRYPOINT /usr/bin/qdb_rest --config-file /etc/qdb/qdb_rest.conf
