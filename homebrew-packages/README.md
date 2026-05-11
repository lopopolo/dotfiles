# Homebrew packages

Package lists are maintained using [`brew bundle`].

[`brew bundle`]: https://github.com/Homebrew/homebrew-bundle

This directory contains a Brewfile per host containing a snapshot of top-level
packages installed using Homebrew. These are machine snapshots rather than a
role-based package taxonomy.

To bootstrap a new system

```shell
make brew_bundle_install
```

These manifests also manage cask installs for bootstrapping a new macOS machine.
Some apps are not tracked here but should be.

TODO apps:

- Google Chrome
- Google Drive
- OneDrive

Programming languages should not be installed globally using Homebrew and
instead should be tracked on a per-package basis with mise.
