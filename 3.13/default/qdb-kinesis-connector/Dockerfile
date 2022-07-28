#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM docker.io/amazonlinux:latest

ENV JVM_GC_MAX_PARALLEL_THREADS=4
ENV JVM_GC_MAX_PAUSE_MS=15000
ENV JVM_MEMORY_LIMIT=
# how much memory is allocated to the JVM, vs off-heap QuasarDB
ENV JVM_HEAP_SIZE_RATIO=25

ENV JMX_ENABLE="false"
ENV JMX_PORT=43210

ENV LOG4J2_XML="/opt/qdb/kinesis/resources/log4j2.xml"

ENV CLUSTER_URI="qdb://127.0.0.1:2836"
ENV CLUSTER_PUBLIC_KEY_FILE=
ENV USER_SECURITY_FILE=

ENV ROLE_ARN=
ENV EXTERNAL_ID=
ENV LOG_PATH="/opt/qdb/kinesis/log"

ENV RELAY_RESET_INTERVAL_MS=3600000
ENV RELAY_QUEUE_SIZE=500
ENV RELAY_POOL_SIZE=10
ENV THREADS=10
ENV METRICS_TAGS=""

ENV PUSH_MODE=
ENV BLACKLIST_FILE=/opt/qdb/kinesis/blacklist.conf

ENV STREAM_NAME=
ENV PARSER=
ENV STOP_AFTER_MS=0
ENV RECORD_REJECTION_AGE_MS=0

ENV KINESIS_PLUGIN_PATH="/opt/qdb/kinesis/lib/"

RUN yum update -y && \
    yum upgrade -y && \
    yum install -y java-17-amazon-corretto-headless \
                   shadow-utils && \
    groupadd -r qdb && \
    useradd -r -g qdb qdb  && \
    yum clean all && \
    rm -rf /var/cache/yum

COPY docker-wrapper.sh /opt/qdb/kinesis/bin/docker-wrapper.sh
COPY log4j2.xml /opt/qdb/kinesis/resources/log4j2.xml
ADD  http://download.quasar.ai/quasardb/3.13/3.13.5/api/kinesis/kinesis-3.13.5-jar-with-dependencies.jar /opt/qdb/kinesis/bin/app.jar

RUN mkdir -p /opt/qdb/kinesis/log && \
    chown -R qdb:qdb /opt/qdb/kinesis && \
    chmod +x /opt/qdb/kinesis/bin/docker-wrapper.sh && \
    \
    mkdir -p ${KINESIS_PLUGIN_PATH} && \
    chown -R qdb:qdb ${KINESIS_PLUGIN_PATH}

USER qdb

ENTRYPOINT ["/opt/qdb/kinesis/bin/docker-wrapper.sh"]

CMD ["java", "-jar", "/opt/qdb/kinesis/bin/app.jar"]
