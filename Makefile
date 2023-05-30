DOTFILES = $(shell ls -1A files)

.PHONY: all
all: bootstrap

.PHONY: bootstrap
bootstrap: dotfiles dev vim

.PHONY: dotfiles
dotfiles: lang-runtimes alacritty git starship tmux $(DOTFILES)

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

.PHONY: tmux
tmux:
	mkdir -p $(HOME)/.config/tmux
	cp $(PWD)/tmux/tmux.conf $(HOME)/.config/tmux/tmux.conf

.PHONY: fmt
fmt:
	npm run fmt
	shfmt -f . | grep -v '^vim/' | xargs -n1 shfmt -i 2 -ci -d -w
	shfmt -i 2 -ci -d -w bash/*.bash
	shfmt -i 2 -ci -d -w zsh/*.zsh

.PHONY: lint
lint:
	shfmt -f . | grep -v '^vim/' | grep -v '\.zsh$$' | xargs shellcheck -x
	find . -name '*.zsh' | grep -v 'vim/' | xargs -n1 zsh -n

.PHONY: brewfile
brewfile:
	rm -f homebrew-packages/Brewfile.`hostname -s`
	brew bundle dump --describe --file=homebrew-packages/Brewfile.`hostname -s`

.PHONY:
brew_bundle_install:
	brew bundle --file=homebrew-packages/Brewfile.`hostname -s`

.PHONY: cargo_bins_install
cargo_bins_install:
	cargo install --locked \
		bindgen-cli \
		cargo-about \
		cargo-bisect-rustc \
		cargo-bloat \
		cargo-deny \
		cargo-diet \
		cargo-expand \
		cargo-fuzz \
		cargo-geiger \
		cargo-insta \
		cargo-mutants \
		cargo-nextest \
		cargo-outdated \
		cargo-tally \
		cargo-udeps \
		flamegraph \
		ucd-generate
	LIBCLANG_PATH=/usr/local/opt/llvm/lib/libclang.dylib cargo install --locked cargo-spellcheck

.PHONY: vim
vim: vim-init

.PHONY: vim-init
vim-init:
	ln -snf $(PWD)/vim/vimrc $(HOME)/.vimrc
	ln -snf $(PWD)/vim $(HOME)/.vim
	mkdir -p $(HOME)/.config/nvim/
	mkdir -p $(HOME)/.local/state/nvim/undo
	ln -snf $(PWD)/vim/init.lua $(HOME)/.config/nvim/init.lua
