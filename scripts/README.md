# Repository Scripts

This directory contains executable compositions of existing repository tools.
Mise tasks name these operations while scripts own multiline shell control flow
and command plumbing. `bootstrap.sh`, `install_homebrew_packages.sh`, and
`refresh_mise.sh` are also mise-independent entry points for a machine that does
not have mise installed yet.

Keep each script readable as shell. After foundational setup, put execution in
functions and leave one deliberate top-level entry point: `main "$@"`.

## Checks

- `format.sh` formats repository-owned text and shell files, or checks them with
  `--check`.
- `lint_shell.sh` runs shellcheck and shfmt over repository-owned shell scripts
  and parses zsh configuration with `zsh -n`.

## Workstation setup

- `bootstrap.sh` installs dotfiles and creates development directories.
- `generate_completions.sh` generates completions that should not run during
  shell startup.
- `install_homebrew_packages.sh` installs the machine-specific Brewfile,
  refreshes signing keys, and installs mise.
- `refresh_mise.sh` verifies and installs the latest official mise release.
- `snapshot_homebrew_packages.sh` refreshes the current machine's Brewfile.
