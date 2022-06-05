# shellcheck shell=bash
# vim: filetype=sh
# Linux specific customizations

alias ls='ls -h --color=auto'
alias sudo='sudo -v; sudo '

# neovim
EDITOR='nvim'
export EDITOR
alias vim='nvim'
complete -o filenames -F _filedir_xspec vim

BROWSER='google-chrome-stable'
export BROWSER

# Bash completion
if [ -f /usr/share/git/completion/git-completion.bash ]; then
  # shellcheck disable=SC1091
  source /usr/share/git/completion/git-completion.bash
fi
if [ -f /usr/share/bash-completion/completions/git ]; then
  # shellcheck disable=SC1091
  source /usr/share/bash-completion/completions/git
fi

if [ -f /etc/bash_completion ]; then
  # shellcheck disable=SC1091
  source /etc/bash_completion
fi

# fzf
## Arch
if [ -f /usr/share/fzf/key-bindings.bash ]; then
  # shellcheck disable=SC1091
  source /usr/share/fzf/key-bindings.bash
  # shellcheck disable=SC1091
  source /usr/share/fzf/completion.bash
fi
## Ubuntu / Debian
if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
  # shellcheck disable=SC1091
  source /usr/share/doc/fzf/examples/key-bindings.bash
  # shellcheck disable=SC1091
  source /usr/share/doc/fzf/examples/completion.bash
fi
if [ -f $HOME/.fzf/shell/key-bindings.bash ]; then
  source $HOME/.fzf/shell/key-bindings.bash
  source $HOME/.fzf/shell/completion.bash
fi

# HiDPI
export QT_AUTO_SCREEN_SCALE_FACTOR=2
export GDK_SCALE=2

# rbenv
if [ -f "$HOME/.rbenv/bin/rbenv" ]; then
  export PATH="$PATH:$HOME/.rbenv/bin"
fi
# rbenv on linux
export RBENV_ROOT=$HOME/.rbenv
if [[ ":${PATH}:" != *:"${RBENV_ROOT}/shims":* ]]; then
  eval "$(rbenv init -)"
fi

# pyenv
if [ -f "$HOME/.pyenv/bin/pyenv" ]; then
  export PATH="$PATH:$HOME/.pyenv/bin"
fi
# pyenv on linux
if shopt -q login_shell; then
  export PYENV_ROOT="$HOME/.pyenv/bin"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
fi

if command -v pyenv >/dev/null; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# cargo

append_to_path "$HOME/.cargo/bin"

# golang

if [ -d /usr/local/go/bin ]; then
  append_to_path "/usr/local/go/bin"
fi

# =========================================================================== #
# Prompt
# =========================================================================== #

eval "$(starship init bash)"
