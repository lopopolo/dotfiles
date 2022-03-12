DOTFILES = $(shell ls -1A files)

.PHONY: all
all: bootstrap

.PHONY: bootstrap
bootstrap: dotfiles dev vim

.PHONY: dotfiles
dotfiles: lang-runtimes alacritty git starship $(DOTFILES)

.PHONY: $(DOTFILES)
$(DOTFILES):
	ln -snf $(PWD)/files/$@ $(HOME)/$@

.PHONY: lang-runtimes
lang-runtimes:
	ln -snf $(PWD)/.python-version $(HOME)/.python-version
	ln -snf $(PWD)/.ruby-version $(HOME)/.ruby-version

.PHONY: dev
dev:
	mkdir -p $(HOME)/dev/artichoke
	mkdir -p $(HOME)/dev/hyperbola
	mkdir -p $(HOME)/dev/repos

.PHONY: git
git:
	mkdir -p $(HOME)/.config/git
	cp $(PWD)/git/ignore $(HOME)/.config/git/ignore
	cp $(PWD)/git/`hostname -s`.gitconfig $(HOME)/.config/git/config

.PHONY: alacritty
alacritty:
	mkdir -p $(HOME)/.config/alacritty
	cp $(PWD)/alacritty/alacritty.yml $(HOME)/.config/alacritty/alacritty.yml

.PHONY: starship
starship:
	mkdir -p $(HOME)/.config
	cp $(PWD)/starship/starship.toml $(HOME)/.config/starship.toml

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
