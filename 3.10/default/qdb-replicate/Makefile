#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

repo      	:= docker.io
org       	:= bureau14
component 	:= qdb-replicate
variant         := default
build-image	:= build-$(component)
build-tag       := 3.10.2-$(variant)
target-base     := base:$(build-tag)
target-image    := $(repo)/$(org)/$(component)


build:
	docker build --squash --build-arg BASE=$(target-base) --tag $(build-image):$(build-tag) .

tag:
	docker tag $(build-image):$(build-tag) $(target-image):3.10$(variant-tag)
	docker tag $(build-image):$(build-tag) $(target-image):3.10.2$(variant-tag)
	docker tag $(build-image):$(build-tag) $(target-image):stable$(variant-tag)

push:   build tag
	docker push $(target-image):3.10$(variant-tag)
	docker push $(target-image):3.10.2$(variant-tag)
	docker push $(target-image):stable$(variant-tag)

clean:
	docker rmi --force $(build-image)
	docker rmi --force $(target-image)

.PHONY: clean build tag push
