#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

repo      	:= docker.io
org       	:= bureau14
component 	:= qdbsh
variant         := core2
build-image	:= build-$(component)
build-tag       := -$(variant)
target-image    := $(repo)/$(org)/$(component)

variant-tag     := core2

build:
	docker build --build-arg BASE=base: --tag $(build-image):$(build-tag) .

tag:
	docker tag $(build-image):$(build-tag) $(target-image):
	docker tag $(build-image):$(build-tag) $(target-image):

push:   build tag
	docker push $(target-image):-$(variant-tag)
	docker push $(target-image):-$(variant-tag)

clean:
	docker rmi --force $(build-image)
	docker rmi --force $(target-image)

.PHONY: clean build tag push
