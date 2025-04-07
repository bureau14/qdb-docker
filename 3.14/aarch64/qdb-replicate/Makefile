#
# NOTE: THIS MAKEFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
repo      	:= docker.io
org       	:= bureau14
component 	:= qdb-replicate
variant         := aarch64
build-image	:= build-$(component)
build-tag       := 3.14.1-$(variant)
target-base     := base:$(build-tag)
target-image    := $(repo)/$(org)/$(component)

variant-tag     := -aarch64

build:
	docker build --squash --build-arg BASE=$(target-base) --tag $(build-image):$(build-tag) .

tag:
	docker tag $(build-image):$(build-tag) $(target-image):3$(variant-tag)
	docker tag $(build-image):$(build-tag) $(target-image):3.14$(variant-tag)
	docker tag $(build-image):$(build-tag) $(target-image):3.14.1$(variant-tag)
	docker tag $(build-image):$(build-tag) $(target-image):stable$(variant-tag)
	docker tag $(build-image):$(build-tag) $(target-image):latest$(variant-tag)

push:   build tag
	docker push $(target-image):3$(variant-tag)
	docker push $(target-image):3.14$(variant-tag)
	docker push $(target-image):3.14.1$(variant-tag)
	docker push $(target-image):stable$(variant-tag)
	docker push $(target-image):latest$(variant-tag)

clean:
	docker rmi --force $(build-image)
	docker rmi --force $(target-image)

.PHONY: clean build tag push
