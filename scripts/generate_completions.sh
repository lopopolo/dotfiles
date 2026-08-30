#!/usr/bin/env bash
# Generate completions that should not run during shell startup.

set -Eeuo pipefail
IFS=$'\n\t'

main() {
  local completion_dir

  if ! command -v docker > /dev/null; then
    return
  fi

  completion_dir="$HOME/.docker/completions"
  readonly completion_dir
  mkdir -p -- "$completion_dir"
  docker completion zsh > "$completion_dir/_docker"
}

main "$@"
