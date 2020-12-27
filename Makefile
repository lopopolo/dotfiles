DOTFILES = $(shell ls -1A files)
TARGETDIR=$(HOME)

.PHONY: all
all: bootstrap

.PHONY: bootstrap
bootstrap: dotfiles dev vim

.PHONY: dotfiles
dotfiles: $(DOTFILES)
	mkdir -p $(HOME)/.config/alacritty
	cp alacritty/alacritty.yml $(HOME)/.config/alacritty/alacritty.yml

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
	rm homebrew-packages/Brewfile.`hostname -s`
	brew bundle dump --describe --file=homebrew-packages/Brewfile.`hostname -s`

.PHONY: vim
vim: vim-init neovim-provider

.PHONY: vim-init
vim-init:
	ln -snf $(PWD)/vim/vimrc $(HOME)/.vimrc
	ln -snf $(PWD)/vim/gvimrc $(HOME)/.gvimrc
	ln -snf $(PWD)/vim $(HOME)/.vim
	mkdir -p $(HOME)/.config/nvim/
	ln -snf $(PWD)/vim/init.vim $(HOME)/.config/nvim/init.vim
	mkdir -p $(HOME)/.config/nvim/after/plugin
	ln -snf $(PWD)/vim/coc.vim $(HOME)/.config/nvim/after/plugin/coc.vim

.PHONY: neovim-provider
neovim-provider: neovim-node neovim-python

.PHONY: neovim-node
neovim-node:
	npm install -g neovim

.PHONY: neovim-python
neovim-python:
	pyenv install --skip-existing 3.9.0
	pyenv virtualenv --force 3.9.0 neovim3
	eval "$$(pyenv init -)" && \
		pyenv activate neovim3 && \
		pip install --ignore-installed pynvim && \
		pyenv which python
