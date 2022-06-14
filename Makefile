TEMPLATES := $(shell find templates/ -type f)
SUBDIRS := $(shell find . -mindepth 1 -maxdepth 1 -type d -name '[0-9].*' -print0 |  xargs -0 ls -Fd   | sed 's/\(.*\)/"\1"/')

clean:		$(SUBDIRS)
	rm -rf $(SUBDIRS)

apply-templates:	config.json $(TEMPLATES)
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
