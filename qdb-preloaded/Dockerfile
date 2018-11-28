FROM bureau14/qdb

# Install build-time dependencies
COPY qdb-api_${QDB_VERSION}-${QDB_DEB_VERSION}.deb .
COPY qdb-utils_${QDB_VERSION}-${QDB_DEB_VERSION}.deb .
RUN  dpkg -i qdb-api_${QDB_VERSION}-${QDB_DEB_VERSION}.deb
RUN  dpkg -i qdb-utils_${QDB_VERSION}-${QDB_DEB_VERSION}.deb

# Load datasets
ADD     ./datasets /datasets
ADD     preloader.sh .
RUN     ./preloader.sh

# Cleanup
RUN rm -R /datasets ./preloader.sh
RUN dpkg -r qdb-api qdb-utils

CMD ["--root", "/data"]