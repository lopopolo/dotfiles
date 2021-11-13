DOTFILES = $(shell ls -1A files)
TARGETDIR=$(HOME)

.PHONY: all
all: bootstrap

.PHONY: bootstrap
bootstrap: dotfiles dev vim

.PHONY: dotfiles
dotfiles: lang-runtimes $(DOTFILES)
	mkdir -p $(HOME)/.config/alacritty
	cp alacritty/alacritty.yml $(HOME)/.config/alacritty/alacritty.yml
	cp starship/starship.toml $(HOME)/.config/starship.toml

.PHONY: $(DOTFILES)
$(DOTFILES):
	ln -snf $(PWD)/files/$@ $(TARGETDIR)/$@
	ln -snf $(PWD)/.python-version $(TARGETDIR)/.python-version

.PHONY: lang-runtimes
lang-runtimes:
	ln -snf $(PWD)/.ruby-version $(TARGETDIR)/.ruby-version
	ln -snf $(PWD)/Gemfile $(TARGETDIR)/Gemfile
	ln -snf $(PWD)/Gemfile.lock $(TARGETDIR)/Gemfile.lock

.PHONY: dev
dev:
	mkdir -p $(HOME)/dev/artichoke
	mkdir -p $(HOME)/dev/hyperbola
	mkdir -p $(HOME)/dev/repos

.PHONY: git-config-rjl
git-config-rjl:
	ln -snf $(PWD)/git-configs/rjl-hyperbola.gitconfig $(TARGETDIR)/.gitconfig

.PHONY: git-config-rjl-arch
git-config-rjl-arch:
	ln -snf $(PWD)/git-configs/rjl-hyperbola-arch.gitconfig $(TARGETDIR)/.gitconfig

.PHONY: fmt
fmt:
	npm run fmt
	shfmt -f . | grep -v '^vim/' | xargs shfmt -i 2 -ci -s -d

.PHONY: brewfile
brewfile:
	rm homebrew-packages/Brewfile.`hostname -s`
	brew bundle dump --describe --file=homebrew-packages/Brewfile.`hostname -s`

.PHONY: vim
vim: vim-init neovim-provider neovim-lsp-setup

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
	sudo npm install -g neovim

.PHONY: neovim-python
neovim-python:
	./scripts/initialize-neovim-python-venv.sh

.PHONY: neovim-lsp-setup
neovim-lsp-setup:
	brew install \
		pyright \
		rust-analyzer \
		terraform-ls \
		tflint
	npm install -g \
		bash-language-server \
		dockerfile-language-server-nodejs \
		graphql-language-service-cli \
		typescript \
		typescript-language-server \
		vim-language-server \
		yaml-language-server
