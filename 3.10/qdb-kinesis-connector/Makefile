#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

target      := qdb-kinesis-connector
image       := $(target):3.10.2

all_tags    := docker.io/bureau14/qdb-kinesis-connector:stable docker.io/bureau14/qdb-kinesis-connector:3.10.2 docker.io/bureau14/qdb-kinesis-connector:3.10

build:
	docker buildx build --build-arg BASE=base:3.10.2 --tag $(image) .

tag:    build
	docker tag $(image) $(all_tags)

push:   build tag
        docker push docker.io/bureau14/qdb-kinesis-connector:stable
        docker push docker.io/bureau14/qdb-kinesis-connector:3.10.2
        docker push docker.io/bureau14/qdb-kinesis-connector:3.10

clean:
	docker rmi --force --ignore $(image)
	docker rmi --force --ignore docker.io/bureau14/qdb-kinesis-connector

.PHONY: clean build tag push
