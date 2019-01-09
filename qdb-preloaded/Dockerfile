ARG        BASE_IMAGE="bureau14/qdb"

FROM ${BASE_IMAGE}

ARG        QDB_VERSION=


# Install qdb-server package
ADD     qdb-${QDB_VERSION}-linux-64bit-utils.tar.gz /opt/qdb/
ADD     qdb-${QDB_VERSION}-linux-64bit-c-api.tar.gz /opt/qdb/

ADD     ./datasets /datasets
ADD     preloader.sh .

RUN  ./preloader.sh && \
     rm -R /datasets ./preloader.sh

CMD ["--rocksdb-root", "/data"]
