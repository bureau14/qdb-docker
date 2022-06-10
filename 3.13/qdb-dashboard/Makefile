#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

repo      	:= docker.io
org       	:= bureau14
component 	:= qdb-dashboard
build-image	:= build-$(component)
build-tag       := 3.13.3
target-image    := $(repo)/$(org)/$(component)

build:
	docker build --build-arg BASE=base:3.13.3 --tag $(build-image):$(build-tag) .

tag:
	docker tag $(build-image):$(build-tag) $(target-image):beta
	docker tag $(build-image):$(build-tag) $(target-image):latest
	docker tag $(build-image):$(build-tag) $(target-image):3.13.3
	docker tag $(build-image):$(build-tag) $(target-image):3.13

push:   build tag
	docker push $(target-image):beta
	docker push $(target-image):latest
	docker push $(target-image):3.13.3
	docker push $(target-image):3.13

clean:
	docker rmi --force --ignore $(build-image)
	docker rmi --force --ignore $(target-image)

.PHONY: clean build tag push
