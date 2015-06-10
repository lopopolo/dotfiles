CWD = $(shell pwd)
DOTFILES = $(shell ls -1A files)
TARGETDIR=$(HOME)

all: bootstrap

bootstrap: $(DOTFILES) vim

$(DOTFILES):
	ln -snf $(CWD)/files/$@ $(TARGETDIR)/$@

vim:
	ln -snf $(HOME)/.vim/vimrc $(HOME)/.vimrc
	ln -snf $(HOME)/.vim/gvimrc $(HOME)/.gvimrc

git-config-rjl:
	ln -snf $(CWD)/git-configs/rjl-hyperbola.gitconfig $(TARGETDIR)/.gitconfig

git-config-box:
	ln -snf $(CWD)/git-configs/lopopolo-box.gitconfig $(TARGETDIR)/.gitconfig

.PHONY: $(DOTFILES) vim
