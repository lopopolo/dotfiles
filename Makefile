DOTFILES = $(shell ls -1A files)

.PHONY: all
all: bootstrap

.PHONY: bootstrap
bootstrap: dotfiles dev vim

.PHONY: dotfiles
dotfiles: autoremove-legacy ghostty git starship terraform tmux $(DOTFILES)

.PHONY: $(DOTFILES)
$(DOTFILES):
	ln -snf $(PWD)/files/$@ $(HOME)/$@
	mkdir -p $(HOME)/.terraform.d/plugin-cache

.PHONY: autoremove-legacy
autoremove-legacy:
	rm -rf $(HOME)/.config/alacritty
	rm -rf $(HOME)/.config/mise
	rm -f $(HOME)/.python-version
	rm -f $(HOME)/.ruby-version

.PHONY: dev
dev:
	mkdir -p $(HOME)/dev/artichoke
	mkdir -p $(HOME)/dev/hyperbola
	mkdir -p $(HOME)/dev/repos

.PHONY: git
git:
	mkdir -p $(HOME)/.config/git
	cp $(PWD)/git/ignore $(HOME)/.config/git/ignore
	if [ "$$(hostname -s)" != "Mac" ]; then \
		cp $(PWD)/git/`hostname -s`.gitconfig $(HOME)/.config/git/config; \
		fi

.PHONY: ghostty
ghostty:
	mkdir -p $(HOME)/.config/ghostty
	cp $(PWD)/ghostty/config $(HOME)/.config/ghostty/config

.PHONY: starship
starship:
	mkdir -p $(HOME)/.config
	cp $(PWD)/starship/starship.toml $(HOME)/.config/starship.toml

.PHONY: terraform
terraform:
	mkdir -p $(HOME)/.terraform.d/plugin-cache

.PHONY: tmux
tmux:
	mkdir -p $(HOME)/.config/tmux
	cp $(PWD)/tmux/tmux.conf $(HOME)/.config/tmux/tmux.conf

.PHONY: fmt
fmt:
	npm run fmt
	shfmt -f . | grep -v '^vim/' | xargs -n1 shfmt -i 2 -ci -d -w
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
	LIBCLANG_PATH=/opt/homebrew/opt/llvm/lib/libclang.dylib cargo install --locked cargo-spellcheck

.PHONY: vim
vim: vim-init

.PHONY: vim-init
vim-init:
	ln -snf $(PWD)/vim/vimrc $(HOME)/.vimrc
	ln -snf $(PWD)/vim $(HOME)/.vim
	mkdir -p $(HOME)/.config/nvim/
	mkdir -p $(HOME)/.local/state/nvim/undo
	ln -snf $(PWD)/vim/init.lua $(HOME)/.config/nvim/init.lua
	ln -snf $(PWD)/vim/nvim-pack-lock.json $(HOME)/.config/nvim/nvim-pack-lock.json
