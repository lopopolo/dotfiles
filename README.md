# Dotfiles

Configs and scripts for making a machine feel like `$HOME`.

## Setup

`git clean` in my home directory terrifies me, so these dotfiles are scoped to a
subdirectory of `$HOME` and can bootstrap themselves by making symlinks or
copying files into `.config`.

These dotfiles assume they are located at `$HOME/.dotfiles`.

```shell
cd $HOME
git clone git@github.com:lopopolo/dotfiles.git .dotfiles
cd .dotfiles
make
```

## Homebrew

Homebrew is a package manager for macOS. [Installation
instructions][install-brew].

[install-brew]: https://docs.brew.sh/Installation

Packages for each machine are found in [homebrew-packages](homebrew-packages).

Install packages for the current machine using:

```shell
make brew_bundle_install
```

## Shell

This repository ships with shell configuration files for `bash` and `zsh`. See
the READMEs in the config directories for details:

- [`bash`](bash)
- [`zsh`](zsh)

## Languages

These dotfiles setup version managers for Ruby and Python.

### Ruby

```shell
rbenv install "$(cat $HOME/.ruby-version)"
```

### Python

```shell
pyenv install "$(cat $HOME/.python-version)"
```
