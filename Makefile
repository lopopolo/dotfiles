DOTFILES = $(shell ls -1A files)
BUNDLES=$(wildcard vim/bundle/*)
TARGETDIR=$(HOME)

.PHONY: all
all: bootstrap

.PHONY: bootstrap
bootstrap: $(DOTFILES) dev vim

.PHONY: $(DOTFILES)
$(DOTFILES):
	ln -snf $(PWD)/files/$@ $(TARGETDIR)/$@

.PHONY: dev
dev:
	mkdir -p $(HOME)/dev/repos
	mkdir -p $(HOME)/dev/gopath/bin
	mkdir -p $(HOME)/dev/gopath/pkg
	mkdir -p $(HOME)/dev/gopath/src

.PHONY: git-config-rjl
git-config-rjl:
	ln -snf $(PWD)/git-configs/rjl-hyperbola.gitconfig $(TARGETDIR)/.gitconfig

.PHONY: brewfile
brewfile:
	brew leaves -1 | awk '{ print "brew '"'"'" $$1 "'"'"'" }' | git diff --no-index --word-diff homebrew-packages/Brewfile.`hostname -s` -

.PHONY: vim
vim: vim-init update-vim-bundles

.PHONY: vim-init
vim-init:
	git submodule update --init
	ln -snf $(PWD)/vim/vimrc $(HOME)/.vimrc
	ln -snf $(PWD)/vim/gvimrc $(HOME)/.gvimrc
	ln -snf $(PWD)/vim $(HOME)/.vim

.PHONY: $(BUNDLES)
$(BUNDLES):
	cd "$@" && git checkout master && git pull

.PHONY: update-vim-bundles
update-vim-bundles: $(BUNDLES)
