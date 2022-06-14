#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

ARG        BASE
FROM       ${BASE}

ADD --chown=${QDB_USER}:${QDB_GROUP} http://download.quasar.ai/quasardb/3.10/3.10.2/api/c/qdb-3.10.2-linux-64bit-core2-c-api.tar.gz /opt/qdb/
ADD --chown=${QDB_USER}:${QDB_GROUP} http://download.quasar.ai/quasardb/3.10/3.10.2/rest/qdb-3.10.2-linux-64bit-rest.tar.gz /opt/qdb/
RUN    cd /opt/qdb                    \
    && find . -name "*.tar.gz" -exec tar -xvzf {} \; \
    && rm -f ./*.tar.gz

COPY docker-wrapper.sh /docker-wrapper.sh

ENTRYPOINT ["/docker-wrapper.sh"]
