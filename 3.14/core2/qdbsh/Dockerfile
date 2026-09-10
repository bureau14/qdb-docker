#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
ARG        BASE
FROM       ${BASE} AS build
ARG        BASE

ADD --chown=qdb:qdb http://download.quasar.ai/quasardb/3.14/3.14.3/utils/qdb-3.14.3-linux-64bit-core2-utils.tar.gz /opt/qdb/
RUN cd /opt/qdb && tar -xzvf ./*.tar.gz

FROM       ${BASE}
COPY --chown=qdb:qdb --from=build /opt/qdb/bin/qdbsh /opt/qdb/bin/qdbsh

# qdbsh writes its default log relative to the working directory. Keep it under
# the qdb-owned application directory so inherited POSIX permissions remain writable.
WORKDIR /opt/qdb

ENTRYPOINT ["/opt/qdb/bin/qdbsh"]
