#!/usr/bin/env bash

set -e

echo "Pulling existing containers.."

docker-compose pull

echo "Building Kafka connector"

cd kafka-connect-qdb && \
    wget https://download.quasardb.net/quasardb/nightly/api/c/qdb-3.0.0master-linux-64bit-c-api.tar.gz && \
    wget https://download.quasardb.net/quasardb/nightly/api/kafka/kafka-connect-qdb-3.0.0-SNAPSHOT-standalone.jar

docker-compose build --no-cache

echo "Launching QuasarDB and Kafka"

docker-compose up -d qdb-server kafka

echo "Waiting 3 seconds.."

sleep 3

echo "Creating 'test' table.."
docker-compose run qdbsh -c "CREATE TABLE test(col1 INT64, col2 DOUBLE, col3 BLOB)"

echo "Waiting for kafka to come online.."
sleep 10

echo "Launching kafka-connect"
docker-compose up -d kafka-connect-qdb

echo "Sending 3 test rows to Kafka"

echo '{"col1": 1234, "col2": 5.432, "col3": "hello, world!"}' | docker-compose exec -T kafka /opt/kafka/bin/kafka-console-producer.sh --topic test --broker-list kafka:9092
echo '{"col1": 2345, "col2": 6.543, "col3": "hello, second world!"}' | docker-compose exec -T kafka /opt/kafka/bin/kafka-console-producer.sh --topic test --broker-list kafka:9092
echo '{"col1": 3456, "col2": 7.654, "col3": "bye, world!"}' | docker-compose exec -T kafka /opt/kafka/bin/kafka-console-producer.sh --topic test --broker-list kafka:9092

sleep 3

echo "Showing data in QuasarDB:"
docker-compose run qdbsh -c "SELECT * FROM test"


echo "Launching dashboard at https://localhost:40000.."
docker-compose up -d qdb-dashboard
