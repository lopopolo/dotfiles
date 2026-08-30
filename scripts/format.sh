#!/usr/bin/env bash
# Format repository files or verify that they are already formatted.

set -Eeuo pipefail
IFS=$'\n\t'

shell_files() {
  local shell_file

  while IFS= read -r shell_file; do
    [[ -n $shell_file ]] || continue
    case $shell_file in
      node_modules/* | vim/* | *.zsh)
        continue
        ;;
    esac
    printf '%s\n' "$shell_file"
  done < <(shfmt -f .)
}

format_shell() {
  local -r mode=$1
  local shell_file shell_listing
  local -a files=()

  shell_listing=$(shell_files)
  readonly shell_listing
  while IFS= read -r shell_file; do
    [[ -n $shell_file ]] || continue
    files+=("$shell_file")
  done <<< "$shell_listing"

  if [[ ${#files[@]} -eq 0 ]]; then
    return
  fi

  if [[ $mode == check ]]; then
    shfmt -d -- "${files[@]}"
  else
    shfmt -w -- "${files[@]}"
  fi
}

main() {
  local mode=write

  if (($# > 1)); then
    echo "usage: scripts/format.sh [--check]" >&2
    return 2
  fi
  if (($# == 1)); then
    if [[ $1 != --check ]]; then
      echo "usage: scripts/format.sh [--check]" >&2
      return 2
    fi
    mode=check
  fi
  readonly mode

  cd "$(git rev-parse --show-toplevel)"
  if [[ $mode == check ]]; then
    pnpm exec prettier --check '**/*'
  else
    pnpm run fmt
  fi
  format_shell "$mode"
}

main "$@"
