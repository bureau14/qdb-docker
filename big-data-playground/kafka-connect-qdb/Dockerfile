FROM openjdk:8u171-jre

RUN apt-get update \
        && apt-get install -y wget \
        && mkdir -p /opt \
        && cd /opt \
        && wget http://apache.40b.nl/kafka/2.0.0/kafka_2.12-2.0.0.tgz \
        && tar -xzf ./kafka* \
        && ln -s /opt/kafka_2.12-2.0.0 /opt/kafka

COPY kafka-connect-qdb-3.0.0-SNAPSHOT-standalone.jar /usr/local/share/kafka/plugins/
COPY worker.properties /opt/kafka/config/worker.properties
COPY connector.properties /opt/kafka/config/connector.properties

COPY qdb-3.0.0master-linux-64bit-c-api.tar.gz /usr
RUN cd /usr && tar -xzf ./qdb-3.0.0master-linux-64bit-c-api.tar.gz
ENTRYPOINT /opt/kafka/bin/connect-standalone.sh /opt/kafka/config/worker.properties /opt/kafka/config/connector.properties
