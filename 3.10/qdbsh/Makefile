#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

repo      	:= docker.io
org       	:= bureau14
component 	:= qdbsh
variant         := default
build-image	:= build-$(component)
build-tag       := 3.10.2-$(variant)
target-image    := $(repo)/$(org)/$(component)

variant-tag     := ""

build:
	docker build --build-arg BASE=base:3.10.2 --tag $(build-image):$(build-tag) .

tag:
	docker tag $(build-image):$(build-tag) $(target-image):stable
	docker tag $(build-image):$(build-tag) $(target-image):3.10.2
	docker tag $(build-image):$(build-tag) $(target-image):3.10

push:   build tag
	docker push $(target-image):stable-$(variant-tag)
	docker push $(target-image):3.10.2-$(variant-tag)
	docker push $(target-image):3.10-$(variant-tag)

clean:
	docker rmi --force $(build-image)
	docker rmi --force $(target-image)

.PHONY: clean build tag push
