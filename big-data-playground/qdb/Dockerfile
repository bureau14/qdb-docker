FROM ubuntu:bionic

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates && apt clean
RUN echo "deb [trusted=yes] https://repo.quasardb.net/apt/ /" > /etc/apt/sources.list.d/quasardb.list
RUN apt-get update && apt-get install -y apt-utils \
                                         iproute2 \
                                         locales \
                                         net-tools \
                                         qdb-api \
                                         qdb-rest \
                                         qdb-server \
                                         qdb-utils

# Fixing debconf warning about TERM
ENV  DEBIAN_FRONTEND teletype
RUN  locale-gen en_US.UTF-8

COPY docker-wrapper.sh /docker-wrapper.sh

ENTRYPOINT ["/docker-wrapper.sh"]
