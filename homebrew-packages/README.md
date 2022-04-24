# Homebrew packages

Package lists are maintained using [`brew bundle`].

This directory contains a Brewfile per host containing a list of top-level
packages installed using homebrew.

To bootstrap a new system

```shell
make brew_bundle_install
```

[`brew bundle`]: https://github.com/Homebrew/homebrew-bundle
