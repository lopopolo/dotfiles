HOSTNAME = $(shell hostname -s)
DOTFILES_DIR = $(CURDIR)

define link_dotfile
	@if [ -e "$(2)" ] && [ ! -L "$(2)" ]; then \
		echo "Refusing to overwrite non-symlink: $(2)"; \
		exit 1; \
	fi
	ln -snf "$(1)" "$(2)"
endef

.PHONY: all
all: bootstrap

.PHONY: bootstrap
bootstrap: dotfiles completions dev vim

.PHONY: dotfiles
dotfiles: editline ghostty git python readline ruby shell starship terraform tmux

.PHONY: dev
dev:
	mkdir -p $(HOME)/dev/artichoke
	mkdir -p $(HOME)/dev/hyperbola
	mkdir -p $(HOME)/dev/repos

.PHONY: git
git:
	mkdir -p $(HOME)/.config/git
	cp $(DOTFILES_DIR)/git/ignore $(HOME)/.config/git/ignore
	cp $(DOTFILES_DIR)/git/config.common $(HOME)/.config/git/config.common
	if [ ! -f "$(DOTFILES_DIR)/git/$(HOSTNAME).gitconfig" ]; then \
		echo "Missing host Git config: git/$(HOSTNAME).gitconfig"; \
		exit 1; \
	fi
	cp $(DOTFILES_DIR)/git/$(HOSTNAME).gitconfig $(HOME)/.config/git/config

.PHONY: editline
editline:
	$(call link_dotfile,$(DOTFILES_DIR)/editline/editrc,$(HOME)/.editrc)

.PHONY: ghostty
ghostty:
	mkdir -p $(HOME)/.config/ghostty
	cp $(DOTFILES_DIR)/ghostty/config $(HOME)/.config/ghostty/config

.PHONY: python
python:
	$(call link_dotfile,$(DOTFILES_DIR)/python/pdbrc,$(HOME)/.pdbrc)

.PHONY: readline
readline:
	$(call link_dotfile,$(DOTFILES_DIR)/readline/inputrc,$(HOME)/.inputrc)

.PHONY: ruby
ruby:
	$(call link_dotfile,$(DOTFILES_DIR)/ruby/irbrc,$(HOME)/.irbrc)

.PHONY: shell
shell:
	$(call link_dotfile,$(DOTFILES_DIR)/shell/hushlogin,$(HOME)/.hushlogin)

.PHONY: starship
starship:
	mkdir -p $(HOME)/.config
	cp $(DOTFILES_DIR)/starship/starship.toml $(HOME)/.config/starship.toml

.PHONY: terraform
terraform:
	$(call link_dotfile,$(DOTFILES_DIR)/terraform/terraformrc,$(HOME)/.terraformrc)
	mkdir -p $(HOME)/.terraform.d/plugin-cache

.PHONY: tmux
tmux:
	mkdir -p $(HOME)/.config/tmux
	cp $(DOTFILES_DIR)/tmux/tmux.conf $(HOME)/.config/tmux/tmux.conf

.PHONY: completions
completions:
	if command -v docker > /dev/null; then \
		mkdir -p $(HOME)/.docker/completions; \
		docker completion zsh > $(HOME)/.docker/completions/_docker; \
	fi

.PHONY: fmt
fmt:
	npm run fmt
	shfmt -f . | grep -v '^vim/' | grep -v '\.zsh$$' | xargs -n1 shfmt -i 2 -ci -sr -w

.PHONY: fmt-check
fmt-check:
	npm exec -- prettier --check '**/*'
	shfmt -f . | grep -v '^vim/' | grep -v '\.zsh$$' | xargs -n1 shfmt -i 2 -ci -sr -d

.PHONY: lint
lint:
	shfmt -f . | grep -v '^vim/' | grep -v '\.zsh$$' | xargs shellcheck -x
	find . -name '*.zsh' | grep -v 'vim/' | xargs -n1 zsh -n

.PHONY: brewfile
brewfile:
	rm -f homebrew-packages/Brewfile.`hostname -s`
	brew bundle dump --describe --file=homebrew-packages/Brewfile.`hostname -s`

.PHONY: brew_bundle_install
brew_bundle_install:
	brew bundle --file=homebrew-packages/Brewfile.$(HOSTNAME)

.PHONY: cargo_bins_install
cargo_bins_install:
	LIBCLANG_PATH=/opt/homebrew/opt/llvm/lib/libclang.dylib cargo install --locked cargo-spellcheck

.PHONY: vim
vim: vim-init

.PHONY: vim-init
vim-init:
	$(call link_dotfile,$(DOTFILES_DIR)/vim/vimrc,$(HOME)/.vimrc)
	$(call link_dotfile,$(DOTFILES_DIR)/vim,$(HOME)/.vim)
	mkdir -p $(HOME)/.config/nvim/
	mkdir -p $(HOME)/.local/state/nvim/undo
	$(call link_dotfile,$(DOTFILES_DIR)/vim/init.lua,$(HOME)/.config/nvim/init.lua)
	$(call link_dotfile,$(DOTFILES_DIR)/vim/nvim-pack-lock.json,$(HOME)/.config/nvim/nvim-pack-lock.json)
