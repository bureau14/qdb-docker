#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

ARG        BASE
FROM       ${BASE}

ADD        http://download.quasar.ai/quasardb/3.13/3.13.3/api/c/qdb-3.13.3-linux-64bit-c-api.tar.gz /opt/qdb/
ADD        http://download.quasar.ai/quasardb/3.13/3.13.3/rest/qdb-3.13.3-linux-64bit-rest.tar.gz /opt/qdb/

COPY docker-wrapper.sh /docker-wrapper.sh

ENTRYPOINT ["/docker-wrapper.sh"]
