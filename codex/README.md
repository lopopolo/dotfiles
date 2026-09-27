# Codex

This directory is the repo-managed source for Codex defaults and policy:

- `config.toml` sets the shared approval, sandbox, and web-search defaults.
- `rules/default.rules` holds the reusable command allowlist.
- `hooks.json` and `hooks/lockfile_policy.py` block direct edits to generated
  lockfiles.

`scripts/install_codex_config.sh` merges the managed defaults into `~/.codex`
and copies the policy files. The copies keep active Codex hooks available while
Git checks out commits that do not yet contain these files. Run the installer
again to refresh them after changes. `scripts/bootstrap.sh` runs that
installer. Keep
the command inventory and setting values in their source files rather than
duplicating them here.

The installer preserves Codex's mutable, machine-local state. Keep credentials,
session data, project trust, plugin state, and machine-specific paths out of
this directory.
