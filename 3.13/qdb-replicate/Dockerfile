#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

ARG        BASE
FROM       ${BASE}

ADD        http://download.quasar.ai/quasardb/3.13/3.13.3/utils/qdb-3.13.3-linux-64bit-utils.tar.gz /opt/qdb/

ENTRYPOINT ["/opt/qdb/bin/qdb_replicate"]
