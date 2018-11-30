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
	brew bundle dump --describe --force --file=homebrew-packages/Brewfile.`hostname -s`

.PHONY: vim
vim: vim-init neovim-provider

.PHONY: vim-init
vim-init:
	ln -snf $(PWD)/vim/vimrc $(HOME)/.vimrc
	ln -snf $(PWD)/vim/gvimrc $(HOME)/.gvimrc
	ln -snf $(PWD)/vim $(HOME)/.vim
	mkdir -p $(HOME)/.config/nvim/
	ln -snf $(PWD)/vim/init.vim $(HOME)/.config/nvim/init.vim

.PHONY: neovim-provider
neovim-provider: neovim-node neovim-python

.PHONY: neovim-node
neovim-node:
	npm install -g neovim

.PHONY: neovim-python
neovim-python:
	pyenv install --skip-existing 2.7.15
	pyenv virtualenv --force 2.7.15 neovim2
	eval "$$(pyenv init -)" && pyenv activate neovim2 && pip install neovim && pyenv which python
	pyenv install --skip-existing 3.7.1
	pyenv virtualenv --force 3.7.1 neovim3
	eval "$$(pyenv init -)" && pyenv activate neovim3 && pip install neovim && pyenv which python

.PHONY: $(BUNDLES)
$(BUNDLES):
	cd "$@" && \
		if [[ -n "$$(git rev-parse --show-superproject-working-tree)" ]]; then \
			git checkout master && git pull; \
		fi

.PHONY: vim-update-bundles
vim-update-bundles: $(BUNDLES)
