#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

repo      	:= docker.io
org       	:= bureau14
component 	:= qdb-replicate
build-image	:= build-$(component)
build-tag       := 3.10.2
target-image    := $(repo)/$(org)/$(component)

build:
	docker build --build-arg BASE=base:3.10.2 --tag $(build-image):$(build-tag) .

tag:
	docker tag $(build-image):$(build-tag) $(target-image):stable
	docker tag $(build-image):$(build-tag) $(target-image):3.10.2
	docker tag $(build-image):$(build-tag) $(target-image):3.10

push:   build tag
	docker push $(target-image):stable
	docker push $(target-image):3.10.2
	docker push $(target-image):3.10

clean:
	docker rmi --force --ignore $(build-image)
	docker rmi --force --ignore $(target-image)

.PHONY: clean build tag push
