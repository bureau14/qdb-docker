TEMPLATES := $(shell find templates/ -type f)
SUBDIRS := $(shell jq -r 'keys | map(@sh) | join(" ")' versions.json)

clean:		$(SUBDIRS)
	rm -rf $(SUBDIRS)

apply-templates:	versions.json $(TEMPLATES)
	./apply-templates.sh

check-templates:
	./check-templates.sh

build:     		$(SUBDIRS)

tag:			$(SUBDIRS)

test:           	$(SUBDIRS)

push:      		$(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

all: $(SUBDIRS)

.PHONY: build test tag push
