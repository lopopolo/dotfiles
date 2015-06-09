CWD = $(shell pwd)
DOTFILES = $(shell ls -1A files)
DIRS = bin repos
TARGETDIR=$(HOME)

all: bootstrap

bootstrap: $(DOTFILES) $(DIRS)

$(DOTFILES):
	ln -snf $(CWD)/files/$@ $(TARGETDIR)/$@

$(DIRS):
	ln -snf $(CWD)/$@ $(TARGETDIR)/$@

git-config-rjl:
	ln -snf $(CWD)/git-configs/rjl-hyperbola.gitconfig $(TARGETDIR)/.gitconfig

git-config-box:
	ln -snf $(CWD)/git-configs/lopopolo-box.gitconfig $(TARGETDIR)/.gitconfig

.PHONY: $(DOTFILES) $(DIRS)
