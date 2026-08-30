#!/usr/bin/env bash
# Snapshot top-level Homebrew packages for the current machine.

set -Eeuo pipefail
IFS=$'\n\t'

persistent_hostname() {
  if [[ $(uname -s) == Darwin ]]; then
    scutil --get LocalHostName 2> /dev/null || hostname -s
    return
  fi

  hostname -s
}

main() {
  local dotfiles_root hostname

  dotfiles_root=$(git rev-parse --show-toplevel)
  readonly dotfiles_root
  hostname=$(persistent_hostname)
  readonly hostname

  brew bundle dump --force --no-vscode --no-npm \
    --file="$dotfiles_root/homebrew-packages/Brewfile.$hostname"
}

main "$@"
