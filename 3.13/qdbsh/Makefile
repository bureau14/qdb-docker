#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

target      := qdbsh
image       := $(target):3.13.3

all_tags    := docker.io/bureau14/qdbsh:beta docker.io/bureau14/qdbsh:latest docker.io/bureau14/qdbsh:3.13.3 docker.io/bureau14/qdbsh:3.13

build:
	docker buildx build --build-arg BASE=base:3.13.3 --tag $(image) .

tag:    build
	docker tag $(image) $(all_tags)

push:   build tag
        docker push docker.io/bureau14/qdbsh:beta
        docker push docker.io/bureau14/qdbsh:latest
        docker push docker.io/bureau14/qdbsh:3.13.3
        docker push docker.io/bureau14/qdbsh:3.13

clean:
	docker rmi --force --ignore $(image)
	docker rmi --force --ignore docker.io/bureau14/qdbsh

.PHONY: clean build tag push
