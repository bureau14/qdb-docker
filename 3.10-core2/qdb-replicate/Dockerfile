#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

ARG        BASE
FROM       ${BASE}

ADD --chown=${QDB_USER}:${QDB_GROUP} http://download.quasar.ai/quasardb/3.10/3.10.2/utils/qdb-3.10.2-linux-64bit-core2-utils.tar.gz /opt/qdb/
RUN    cd /opt/qdb                    \
    && tar -xzvf ./*.tar.gz           \
    && rm -f ./*.tar.gz               \

ENTRYPOINT ["/opt/qdb/bin/qdb_replicate"]
