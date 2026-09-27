#!/usr/bin/env bash
# Install repository-managed dotfiles and create development directories.

set -Eeuo pipefail
IFS=$'\n\t'

persistent_hostname() {
  if [[ $(uname -s) == Darwin ]]; then
    scutil --get LocalHostName 2> /dev/null || hostname -s
    return
  fi

  hostname -s
}

link_dotfile() {
  local -r source=$1
  local -r target=$2

  if [[ -e $target && ! -L $target ]]; then
    echo "bootstrap: refusing to overwrite non-symlink: $target" >&2
    return 1
  fi

  ln -snf -- "$source" "$target"
}

install_git_config() {
  local -r dotfiles_root=$1
  local -r hostname=$2
  local -r host_config="$dotfiles_root/git/$hostname.gitconfig"

  if [[ ! -f $host_config ]]; then
    echo "bootstrap: missing host Git config: git/$hostname.gitconfig" >&2
    return 1
  fi

  mkdir -p -- "$HOME/.config/git"
  cp -- "$dotfiles_root/git/ignore" "$HOME/.config/git/ignore"
  cp -- "$dotfiles_root/git/config.common" "$HOME/.config/git/config.common"
  cp -- "$host_config" "$HOME/.config/git/config"
}

install_copied_configs() {
  local -r dotfiles_root=$1

  mkdir -p -- "$HOME/.config/ghostty"
  cp -- "$dotfiles_root/ghostty/config" "$HOME/.config/ghostty/config"

  mkdir -p -- "$HOME/.config/mise"
  cp -- "$dotfiles_root/mise/settings.toml" "$HOME/.config/mise/config.toml"

  mkdir -p -- "$HOME/.config/starship"
  cp -- "$dotfiles_root/starship/starship.toml" \
    "$HOME/.config/starship/starship.toml"

  mkdir -p -- "$HOME/.config/tmux"
  cp -- "$dotfiles_root/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
}

install_linked_configs() {
  local -r dotfiles_root=$1

  link_dotfile "$dotfiles_root/editline/editrc" "$HOME/.editrc"
  link_dotfile "$dotfiles_root/python/pdbrc" "$HOME/.pdbrc"
  link_dotfile "$dotfiles_root/readline/inputrc" "$HOME/.inputrc"
  link_dotfile "$dotfiles_root/ruby/irbrc" "$HOME/.irbrc"
  link_dotfile "$dotfiles_root/shell/hushlogin" "$HOME/.hushlogin"
  link_dotfile "$dotfiles_root/terraform/terraformrc" "$HOME/.terraformrc"

  mkdir -p -- "$HOME/.terraform.d/plugin-cache"
}

install_vim_config() {
  local -r dotfiles_root=$1

  link_dotfile "$dotfiles_root/vim/vimrc" "$HOME/.vimrc"
  link_dotfile "$dotfiles_root/vim" "$HOME/.vim"

  mkdir -p -- "$HOME/.config/nvim" "$HOME/.local/state/nvim/undo"
  link_dotfile "$dotfiles_root/vim/init.lua" "$HOME/.config/nvim/init.lua"
  link_dotfile "$dotfiles_root/vim/nvim-pack-lock.json" \
    "$HOME/.config/nvim/nvim-pack-lock.json"
}

create_development_directories() {
  mkdir -p -- "$HOME/dev/artichoke" "$HOME/dev/hyperbola" "$HOME/dev/repos"
}

main() {
  local dotfiles_root hostname

  dotfiles_root=$(git rev-parse --show-toplevel)
  readonly dotfiles_root
  hostname=$(persistent_hostname)
  readonly hostname

  install_git_config "$dotfiles_root" "$hostname"
  "$dotfiles_root/scripts/install_codex_config.sh"
  install_copied_configs "$dotfiles_root"
  install_linked_configs "$dotfiles_root"
  install_vim_config "$dotfiles_root"
  create_development_directories
  "$dotfiles_root/scripts/generate_completions.sh"
}

main "$@"
