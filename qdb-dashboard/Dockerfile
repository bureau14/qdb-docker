FROM ubuntu:bionic

COPY qdb-api*.deb .
COPY qdb-rest*.deb .
COPY qdb-dashboard*.deb .

RUN apt-get update && \
    apt-get install -y jq \
                       locales \
                       nano \
                       net-tools \
                       openssl \
                       wget && \
    apt-get clean

RUN dpkg -i qdb-api*.deb
RUN dpkg -i qdb-rest*.deb
RUN dpkg -i qdb-dashboard*.deb

COPY docker-wrapper.sh /docker-wrapper.sh

ENTRYPOINT /docker-wrapper.sh
