#
# NOTE: THIS MAKEFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

# depending on host arch we want to build compatible images only
# we filter SUBDIRS to select compatible targets for host arch

ARCH := $(shell uname -m)

ifeq ($(ARCH),x86_64)
	ARCH_DIR_REGEX := ^\./.*\(core2\|default\)$
else ifeq ($(ARCH),aarch64)
	ARCH_DIR_REGEX := ^\./.*aarch64$
else
	$(error Unsupported architecture: $(ARCH))
endif

SUBDIRS := $(shell find . -mindepth 1 -maxdepth 1 -type d -regex "$(ARCH_DIR_REGEX)")

clean:  $(SUBDIRS)

build:	$(SUBDIRS)

tag:	$(SUBDIRS)

push:	$(SUBDIRS)

test:	$(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: clean build tag test push $(SUBDIRS)
