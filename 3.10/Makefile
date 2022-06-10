#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#


SUBDIRS := $(shell find . -mindepth 1 -maxdepth 1 -type d)

build-base:	Dockerfile
	docker build \
		--tag base:3.10.2 \
		-f Dockerfile \
		.

clean-base:
	docker rmi \
		--force \
		--ignore \
		base:3.10.2

build:	build-base $(SUBDIRS)

clean-test:
	docker rm --force --ignore test-qdb-server test-qdbsh

clean:  clean-base clean-test $(SUBDIRS)

tag:	$(SUBDIRS)

push:	$(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)


test:   clean-test
	docker run --detach --network=host -e QDB_BIND_ADDRESS="127.0.0.1"  --rm --name test-qdb-server qdb:3.10.2
	./retry.sh 10 docker run --tty --rm --interactive --name test-qdbsh --network=host qdbsh:3.10.2 -c "int_put sonmi 451"
	docker rm --force --ignore test-qdbsh test-qdb-server

.PHONY: clean build tag test push $(SUBDIRS)
