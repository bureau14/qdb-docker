FROM docker.io/ubuntu:22.04

RUN apt-get update && \
        apt-get upgrade -y && \
        apt-get install -y iproute2 \
                           jq \
                           locales \
                           nano \
                           net-tools \
                           openssl \
                           wget && \
        apt-get clean

# Install our C api and dashboard
ADD     qdb-*-c-api.tar.gz /opt/qdb/
ADD     qdb-*-linux-64bit-rest.tar.gz /opt/qdb/

COPY docker-wrapper.sh /docker-wrapper.sh

ENTRYPOINT /docker-wrapper.sh
