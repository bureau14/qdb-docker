#!/usr/bin/env bash

cd ../../kafka-connect-qdb \
    && mvn package -DskipTests \
    && cp -v target/kafka-connect-qdb-3.0.0-SNAPSHOT-standalone.jar ../qdb-docker/big-data-playground/kafka-connect-qdb \
    && cd ../qdb-docker/big-data-playground/ \
    && docker-compose build
