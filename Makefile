SUBDIRS := $(shell jq -r 'keys | map(@sh) | join(" ")' versions.json)

all: prepare $(SUBDIRS)

prepare:
	./apply-templates.sh

build:     $(SUBDIRS)

push:      $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)


.PHONY: all $(SUBDIRS)
