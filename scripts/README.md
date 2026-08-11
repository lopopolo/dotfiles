# Repository Scripts

This directory contains executable compositions of existing repository tools.
Make targets name these operations while scripts own multiline shell control
flow and command plumbing.

Keep each script readable as shell. After foundational setup, put execution in
functions and leave one deliberate top-level entry point: `main "$@"`.

## Checks

- `lint_shell.sh` runs shellcheck and shfmt over repository-owned shell scripts
  and parses zsh configuration with `zsh -n`.
