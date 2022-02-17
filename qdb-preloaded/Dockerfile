ARG        BASE_IMAGE="bureau14/qdb"

FROM ${BASE_IMAGE}

USER   root

ADD     ./datasets /opt/qdb/datasets
RUN     chown -R qdb:qdb /opt/qdb
USER  qdb

# Install qdb-server package
ADD     qdb-*-utils.tar.gz /opt/qdb/
ADD     qdb-*-c-api.tar.gz /opt/qdb/

ADD     preloader.sh .

RUN  ./preloader.sh
RUN  rm -rf /opt/qdb/datasets
RUN  rm -f ./preloader.sh
