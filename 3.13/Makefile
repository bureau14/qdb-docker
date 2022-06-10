#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#


SUBDIRS := $(shell find . -mindepth 1 -maxdepth 1 -type d)

build-base:	Dockerfile
	docker build \
		--tag base:3.13.3 \
		-f Dockerfile \
		.

clean-base:
	docker rmi \
		--force \
		--ignore \
		base:3.13.3

build:	build-base $(SUBDIRS)

clean-test:
	docker rm --force test-qdb-server test-qdbsh

clean:  clean-base clean-test $(SUBDIRS)

tag:	$(SUBDIRS)

push:	$(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)


test:   clean-test
	docker run --detach --network=host -e QDB_BIND_ADDRESS="127.0.0.1"  --rm --name test-qdb-server build-qdb:3.13.3
	./retry.sh 10 docker run --rm --name test-qdbsh --network=host build-qdbsh:3.13.3 --command cluster_trim
	docker rm --force test-qdbsh test-qdb-server

.PHONY: clean build tag test push $(SUBDIRS)
