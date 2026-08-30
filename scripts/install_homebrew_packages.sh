#!/usr/bin/env bash
# Install the current machine's Homebrew bundle and refresh mise.

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

  brew bundle --file="$dotfiles_root/homebrew-packages/Brewfile.$hostname"
  "$dotfiles_root/scripts/import_signing_keys.sh"
  "$dotfiles_root/scripts/install_mise.sh"
}

main "$@"
