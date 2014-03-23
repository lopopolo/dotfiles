
.PHONY: force bundles update-bundles

BUNDLES=$(wildcard bundle/*)
VIMDIR=$(pwd)

all: update-bundles

$(BUNDLES): force
	cd "$@" && git checkout master && git pull

update-bundles: $(BUNDLES)
