# zsh Config

The zsh configuration files in this directory have no effect until they are
sourced in the current user's `~/.zshrc`.

This example configuration assumes `gpg` and [Secretive] are installed with
Homebrew.

[secretive]: https://github.com/maxgoedjen/secretive

## `.zshrc`

### Example

```zsh
# Uncomment below to enable profiling and access in the new shell with the
# `zprof` command.
#
# zmodload zsh/zprof

# install fzf keybindings with `/usr/local/opt/fzf/install --xdg`
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh

export GPG_TTY=`tty`
export SSH_AUTH_SOCK=/Users/lopopolo/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

source "$HOME/.dotfiles/zsh/dotfiles.zsh"
```

### Caveats

- rustup will dump some lines to `.zshrc` here when installing for the first
  time. These lines are already included in this directory's zsh configuration.
  Remove them from `.zshrc` after rustup is installed.

## `.zprofile`

### Example

```zsh
# This is needed to prevent `path_helper` from mucking with the PATH when
# launching tmux.
#
# See: https://superuser.com/a/583502
if [ -f /etc/profile ]; then
  PATH=""
  source /etc/profile
fi
```

### Caveats

- rustup will dump some lines to `.zprofile` here when installing for the first
  time. These lines are already included in this directory's zsh configuration.
  Remove them from `.zprofile` after rustup is installed.
