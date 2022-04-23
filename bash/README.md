# bash Config

The bash configuration files in this directory have no effect until they are
sourced in the current user's `~/.bashrc` and `~/.bash_profile`.

This example configuration assumes `gpg` and [Secretive] are installed with
Homebrew.

[secretive]: https://github.com/maxgoedjen/secretive

## `.bashrc`

### Example

```bash
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export GPG_TTY=`tty`
export SSH_AUTH_SOCK=/Users/lopopolo/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

. "$HOME/.dotfiles/bash/dotfiles.bash"
```

### Caveats

- rustup will dump some lines to `.bash_profile` here when installing for the
  first time. These lines are already included in this directory's bash
  configuration. Remove them from `.bash_profile` after rustup is installed.

## `.bash_profile`

### Example

```bash
# This is needed to prevent `path_helper` from mucking with the PATH when
# launching tmux.
#
# See: https://superuser.com/a/583502
if [ -f /etc/profile ]; then
  PATH=""
  source /etc/profile
fi

. "$HOME/.bashrc"
```

### Caveats

- rustup will dump some lines to `.bash_profile` here when installing for the
  first time. These lines are already included in this directory's bash
  configuration. Remove them from `.bash_profile` after rustup is installed.
