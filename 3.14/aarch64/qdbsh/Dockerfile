#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
ARG        BASE
FROM       ${BASE} AS build
ARG        BASE

ADD --chown=qdb:qdb https://download.quasar.ai/quasardb/3.14/3.14.1/utils/qdb-3.14.1-linux-64bit-aarch64-utils.tar.gz /opt/qdb/
RUN cd /opt/qdb && tar -xzvf ./*.tar.gz

FROM       ${BASE}
COPY --chown=qdb:qdb --from=build /opt/qdb/bin/qdbsh /opt/qdb/bin/qdbsh

ENTRYPOINT ["/opt/qdb/bin/qdbsh"]
