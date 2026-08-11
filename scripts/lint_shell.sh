#!/usr/bin/env bash
# Run shellcheck, shfmt, and zsh syntax checks over repository-owned shell.

set -Eeuo pipefail
IFS=$'\n\t'

dispatch() {
  local -r tool=$1
  local -r mise=${MISE:-mise}
  shift

  if command -v "$mise" > /dev/null 2>&1; then
    "$mise" exec -- "$tool" "$@"
    return
  fi

  command "$tool" "$@"
}

shellcheck() {
  dispatch shellcheck "$@"
}

shfmt() {
  dispatch shfmt "$@"
}

lint_shell_scripts() {
  local shell_file shell_listing
  local -a shell_files=()

  shell_listing=$(shfmt -f .)
  readonly shell_listing
  while IFS= read -r shell_file; do
    [[ -n $shell_file ]] || continue
    case "$shell_file" in
      node_modules/* | vim/* | *.zsh)
        continue
        ;;
    esac
    shell_files+=("$shell_file")
  done <<< "$shell_listing"

  if [[ ${#shell_files[@]} -gt 0 ]]; then
    shellcheck -x -- "${shell_files[@]}"
    shfmt -d -- "${shell_files[@]}"
  fi
}

lint_zsh_scripts() {
  local shell_file zsh_listing
  local -a zsh_files=()

  zsh_listing=$(find . \
    \( -path './.git' -o -path './node_modules' -o -path './vim' \) -prune \
    -o -type f -name '*.zsh' -print)
  readonly zsh_listing
  while IFS= read -r shell_file; do
    [[ -n $shell_file ]] || continue
    zsh_files+=("$shell_file")
  done <<< "$zsh_listing"

  for shell_file in "${zsh_files[@]}"; do
    zsh -n "$shell_file"
  done
}

main() {
  local repo_root

  repo_root=$(git rev-parse --show-toplevel)
  readonly repo_root
  cd "$repo_root"

  lint_shell_scripts
  lint_zsh_scripts
}

main "$@"
