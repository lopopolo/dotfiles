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

.PHONY: lang-runtimes
lang-runtimes:
	ln -snf $(PWD)/.python-version $(TARGETDIR)/.python-version
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
vim: vim-init

.PHONY: vim-init
vim-init:
	ln -snf $(PWD)/vim/vimrc $(HOME)/.vimrc
	ln -snf $(PWD)/vim/gvimrc $(HOME)/.gvimrc
	ln -snf $(PWD)/vim $(HOME)/.vim
	mkdir -p $(HOME)/.config/nvim/
	ln -snf $(PWD)/vim/init.vim $(HOME)/.config/nvim/init.vim
	mkdir -p $(HOME)/.config/nvim/after/plugin
