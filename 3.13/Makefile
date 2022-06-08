#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#


build-base:
	podman build \
		--tag base-3.13.3 \
		-f Dockerfile \
		.

build-qdbsh:
	podman build \
		--tag "qdbsh:3.13.3" \
		--build-arg BASE="base-3.13.3" \
		-f qdbsh/Dockerfile \
		qdbsh/

build-qdb-replicate:
	podman build \
		--tag "qdb-replicate:3.13.3" \
		--build-arg BASE="base-3.13.3" \
		-f qdb-replicate/Dockerfile \
		qdb-replicate/

build-qdb-kinesis-connector:
	podman build \
		--tag "qdb-kinesis-connector:3.13.3" \
		-f qdb-kinesis-connector/Dockerfile \
		qdb-kinesis-connector/

build-qdb:
	podman build \
		--build-arg BASE="base-3.13.3" \
		--tag "qdbsh:3.13.3" \
		-f qdb/Dockerfile \
		qdb/

build:		build-base \
		build-qdb \
		build-qdbsh \
		build-qdb-replicate \
		build-qdb-kinesis-connector

all:		build
