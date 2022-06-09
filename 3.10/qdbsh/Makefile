#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

target      := qdbsh
image       := $(target):3.10.2

all_tags    := docker.io/bureau14/qdbsh:stable docker.io/bureau14/qdbsh:3.10.2 docker.io/bureau14/qdbsh:3.10

build:
	docker build --squash --build-arg BASE=base:3.10.2 --tag $(image) .

tag:    build
	docker tag $(image) $(all_tags)

push:   build tag
        docker push docker.io/bureau14/qdbsh:stable
        docker push docker.io/bureau14/qdbsh:3.10.2
        docker push docker.io/bureau14/qdbsh:3.10

clean:
	docker rmi --force --ignore $(image)
	docker rmi --force --ignore docker.io/bureau14/qdbsh

.PHONY: clean build tag push
