FROM bureau14/qdb

# Install build-time dependencies
COPY qdb-api_${QDB_VERSION}-${QDB_DEB_VERSION}.deb .
COPY qdb-utils_${QDB_VERSION}-${QDB_DEB_VERSION}.deb .

ADD     ./datasets /datasets
ADD     preloader.sh .

RUN  dpkg -i qdb-api_${QDB_VERSION}-${QDB_DEB_VERSION}.deb && \
     dpkg -i qdb-utils_${QDB_VERSION}-${QDB_DEB_VERSION}.deb && \
     ./preloader.sh && \
     rm -R /datasets ./preloader.sh && \
     dpkg -r qdb-api qdb-utils

CMD ["--root", "/data"]