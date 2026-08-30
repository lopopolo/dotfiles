#!/usr/bin/env bash
# Import the mise release key and install mise from its signed installer.

set -Eeuo pipefail
IFS=$'\n\t'

main() {
  local dotfiles_root

  dotfiles_root=$(git rev-parse --show-toplevel)
  readonly dotfiles_root

  "$dotfiles_root/scripts/import_signing_keys.sh" mise
  "$dotfiles_root/scripts/install_mise.sh"
}

main "$@"
