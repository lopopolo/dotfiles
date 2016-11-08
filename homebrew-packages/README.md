# Homebrew packages

Package lists are maintained using [`brew bundle`](https://github.com/Homebrew/homebrew-bundle).

This directory contains a Brewfile per host containing a
list of top-level packages installed using homebrew.

To bootstrap a new system

```sh
brew tap bundle
brew bundle --file=$DOTFILES_ROOT/homebrew-packages/Brewfile.`hostname -s`
```
