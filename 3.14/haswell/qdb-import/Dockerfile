#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
ARG        BASE
FROM       ${BASE} AS build
ARG        BASE

ADD --chown=${QDB_USER}:${QDB_GROUP} http://download.quasar.ai/quasardb/3.14/3.14.1/api/c/qdb-3.14.1-linux-64bit-c-api.tar.gz /opt/qdb/
RUN cd /opt/qdb && tar -xzvf ./qdb-*c-api.tar.gz
ADD --chown=${QDB_USER}:${QDB_GROUP} http://download.quasar.ai/quasardb/3.14/3.14.1/utils/qdb-3.14.1-linux-64bit-utils.tar.gz /opt/qdb/
RUN cd /opt/qdb && tar -xzvf ./qdb-*utils.tar.gz

FROM       ${BASE}
COPY --from=build /opt/qdb/lib/libqdb_api.so /usr/local/lib/libqdb_api.so
COPY --chown=qdb:qdb --from=build /opt/qdb/bin/qdb_import /opt/qdb/bin/qdb_import

# We need root to run ldconfig
USER root
RUN ldconfig
USER  ${QDB_USER}:${QDB_GROUP}

RUN /opt/qdb/bin/qdb_import --version


ENTRYPOINT ["/opt/qdb/bin/qdb_import"]
