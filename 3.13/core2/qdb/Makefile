#
# NOTE: THIS MAKEFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
repo      	:= docker.io
org       	:= bureau14
component 	:= qdb
variant         := core2
build-image	:= build-$(component)
build-tag       := 3.13.7-$(variant)
target-base     := base:$(build-tag)
target-image    := $(repo)/$(org)/$(component)

variant-tag     := -core2

build:
	docker build --squash --build-arg BASE=$(target-base) --tag $(build-image):$(build-tag) .

tag:
	docker tag $(build-image):$(build-tag) $(target-image):3.13$(variant-tag)
	docker tag $(build-image):$(build-tag) $(target-image):3.13.7$(variant-tag)
	docker tag $(build-image):$(build-tag) $(target-image):beta$(variant-tag)

push:   build tag
	docker push $(target-image):3.13$(variant-tag)
	docker push $(target-image):3.13.7$(variant-tag)
	docker push $(target-image):beta$(variant-tag)

clean:
	docker rmi --force $(build-image)
	docker rmi --force $(target-image)

.PHONY: clean build tag push
