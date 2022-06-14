#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

SUBDIRS := $(shell find . -mindepth 1 -maxdepth 1 -type d)

clean:  $(SUBDIRS)

build:	$(SUBDIRS)

tag:	$(SUBDIRS)

push:	$(SUBDIRS)

test:	$(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: clean build tag test push $(SUBDIRS)
