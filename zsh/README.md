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

source "$HOME/.dotfiles/zsh/dotfiles.zsh"

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

if command -v fd > /dev/null; then
  # Use fd instead of find for fzf (faster, respects .gitignore)
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

export GPG_TTY=`tty`
export SSH_AUTH_SOCK="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
```

### Caveats

- rustup will dump some lines to `.zshrc` here when installing for the first
  time. These lines are already included in this directory's zsh configuration.
  Remove them from `.zshrc` after rustup is installed.

## `.zprofile`

Should be empty.

### Caveats

- rustup will dump some lines to `.zprofile` here when installing for the first
  time. These lines are already included in this directory's zsh configuration.
  Remove them from `.zprofile` after rustup is installed.
