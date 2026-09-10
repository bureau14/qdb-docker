#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
ARG        BASE
FROM       ${BASE}

ADD --chown=${QDB_USER}:${QDB_GROUP} https://download.quasar.ai/quasardb/3.14/3.14.3/api/c/qdb-3.14.3-linux-64bit-aarch64-c-api.tar.gz /opt/qdb/
ADD --chown=${QDB_USER}:${QDB_GROUP} https://download.quasar.ai/quasardb/3.14/3.14.3/rest/qdb-3.14.3-linux-aarch64-rest.tar.gz /opt/qdb/
RUN    cd /opt/qdb                    \
    && find . -name "*.tar.gz" -exec tar -xvzf {} \; \
    && rm -f ./*.tar.gz

COPY docker-wrapper.sh /docker-wrapper.sh

ENTRYPOINT ["/docker-wrapper.sh"]
