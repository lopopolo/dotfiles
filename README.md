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

The default target runs `make bootstrap`, which:

- installs dotfiles and app configs into `$HOME` and `$HOME/.config`;
- generates shell completions that should not be generated during shell startup;
- creates the standard development directories under `$HOME/dev`;
- links Vim and Neovim configuration.

The bootstrap intentionally refuses to replace existing non-symlink dotfiles.
Move existing files out of the way before rerunning `make`.

## Homebrew

Homebrew is a package manager for macOS. [Installation
instructions][install-brew].

[install-brew]: https://docs.brew.sh/Installation

Packages for each machine are found in [`homebrew-packages`](homebrew-packages).
These Brewfiles are host snapshots: they capture the top-level Homebrew formulae
and casks installed on each named machine rather than a role-based package
taxonomy. VS Code extensions are restored with Settings Sync, and
language-scoped tools are managed with mise.

Install packages for the current machine using:

```shell
make brew_bundle_install
```

## Shell

This repository ships with shell configuration files for `zsh`. See the READMEs
in the config directories for details:

- [`zsh`](zsh)

## Languages

These dotfiles setup the [`mise`] version manager which should be used to manage
Python, Ruby, Node.js, and Go installs.

[`mise`]: https://github.com/jdx/mise

```shell
mise install --locked
```

See [Dependency and Supply Chain Posture] for the ownership and update policy.

[Dependency and Supply Chain Posture]: ./docs/dependencies.md
