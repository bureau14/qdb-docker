#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

SUBDIRS              := $(shell find . -mindepth 1 -maxdepth 1 -type d)
version              := 3.14.1
variant              := core2
build-tag            := $(version)-$(variant)
target-base          := base:$(build-tag)
target-qdb           := build-qdb:$(build-tag)
target-qdb-dashboard := build-qdb-dashboard:$(build-tag)
target-qdbsh         := build-qdbsh:$(build-tag)
target-qdb-import    := build-qdb-import:$(build-tag)

build-base:	Dockerfile
	docker build \
                --squash \
		--tag $(target-base) \
		-f Dockerfile \
		.

clean-base:
	docker rmi \
		--force \
                $(target-base)

build:	build-base $(SUBDIRS)

clean-test:
	docker rm --force test-qdb-server test-qdbsh test-qdb-dashboard

clean:  clean-base clean-test $(SUBDIRS)

tag:	$(SUBDIRS)

push:	$(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)


test:   clean-test
	docker run --detach --network=host -e QDB_BIND_ADDRESS="127.0.0.1"  --rm --name test-qdb-server $(target-qdb)
	docker run --detach --network=host -e QDB_URI="qdb://127.0.0.1:2836" --rm --name test-qdb-dashboard $(target-qdb-dashboard)
	../../scripts/retry.sh 10 docker run --rm --name test-qdbsh --network=host $(target-qdbsh) --command cluster_trim
	curl -v 'http://localhost:40000/api/login' -H 'Accept: */*' -H 'Origin: http://localhost:40000' -H 'Referer: http://localhost:40000/' -H 'Content-Type: application/json' --data-raw '{"username":"anonymous","secret_key":""}' --compressed
	docker rm --force test-qdbsh test-qdb-server test-qdb-dashboard

.PHONY: clean build tag test push $(SUBDIRS)
