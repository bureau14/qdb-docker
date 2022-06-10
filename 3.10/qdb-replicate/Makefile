#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

target      := qdb-replicate
image       := $(target):3.10.2

all_tags    := docker.io/bureau14/qdb-replicate:stable docker.io/bureau14/qdb-replicate:3.10.2 docker.io/bureau14/qdb-replicate:3.10

build:
	docker build --build-arg BASE=base:3.10.2 --tag $(image) .

tag:    build
	docker tag $(image) $(all_tags)

push:   build tag
        docker push docker.io/bureau14/qdb-replicate:stable
        docker push docker.io/bureau14/qdb-replicate:3.10.2
        docker push docker.io/bureau14/qdb-replicate:3.10

clean:
	docker rmi --force --ignore $(image)
	docker rmi --force --ignore docker.io/bureau14/qdb-replicate

.PHONY: clean build tag push
