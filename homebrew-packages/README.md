# Homebrew packages

This directory contains snapshots of packages installed
using homebrew. To update a particular host's list, run
the following command:

```
brew leaves > $DOTFILES_ROOT/homebrew-packages/`hostname -s`.txt
```
