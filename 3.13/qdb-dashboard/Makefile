#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

repo      	:= docker.io
org       	:= bureau14
component 	:= qdb-dashboard
variant         := default
build-image	:= build-$(component)
build-tag       := 3.13.3-$(variant)
target-image    := $(repo)/$(org)/$(component)

variant-tag     := ""

build:
	docker build --build-arg BASE=base:3.13.3 --tag $(build-image):$(build-tag) .

tag:
	docker tag $(build-image):$(build-tag) $(target-image):beta
	docker tag $(build-image):$(build-tag) $(target-image):latest
	docker tag $(build-image):$(build-tag) $(target-image):3.13.3
	docker tag $(build-image):$(build-tag) $(target-image):3.13

push:   build tag
	docker push $(target-image):beta-$(variant-tag)
	docker push $(target-image):latest-$(variant-tag)
	docker push $(target-image):3.13.3-$(variant-tag)
	docker push $(target-image):3.13-$(variant-tag)

clean:
	docker rmi --force $(build-image)
	docker rmi --force $(target-image)

.PHONY: clean build tag push
