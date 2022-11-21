#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

ARG        BASE
FROM       ${BASE} AS build
ARG        BASE

ADD --chown=${QDB_USER}:${QDB_GROUP} http://download.quasar.ai/quasardb/3.10/3.10.2/api/c/qdb-3.10.2-linux-64bit-core2-c-api.tar.gz /opt/qdb/
RUN cd /opt/qdb && tar -xzvf ./qdb-*c-api.tar.gz
ADD --chown=${QDB_USER}:${QDB_GROUP} http://download.quasar.ai/quasardb/3.10/3.10.2/utils/qdb-3.10.2-linux-64bit-core2-utils.tar.gz /opt/qdb/
RUN cd /opt/qdb && tar -xzvf ./qdb-*utils.tar.gz

FROM       ${BASE}
COPY --from=build /opt/qdb/lib/libqdb_api.so /usr/local/lib/libqdb_api.so
COPY --chown=qdb:qdb --from=build /opt/qdb/bin/qdb_import /opt/qdb/bin/qdb_import

USER root
RUN ldconfig
USER ${QDB_USER}

RUN /opt/qdb/bin/qdb_import --version


ENTRYPOINT ["/opt/qdb/bin/qdb_import"]
