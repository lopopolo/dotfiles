# shellcheck shell=zsh
# vim: filetype=sh

# initialize completion system
# https://docs.brew.sh/Shell-Completion
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi
# case insensitive auto completion
# https://superuser.com/a/1092328
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

EDITOR="$(command -v vim)"
export EDITOR

if [[ "$(uname)" == "Darwin" ]]; then
  # shellcheck source=zsh/macos.zsh
  source "$HOME/.dotfiles/zsh/macos.zsh"
fi

# TERM setup
export CLICOLOR=1
export TERM="xterm-256color"

# zsh history
# https://www.soberkoder.com/better-zsh-history/
# https://github.com/ohmyzsh/ohmyzsh/blob/a879ff1515b6bd80eea695c03e22289bd6743718/lib/history.zsh
HISTFILE="$HOME/.zsh_history"
HISTFILESIZE=1000000000
HISTSIZE=1000000000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

# vi mode
bindkey -v

# =========================================================================== #
# Aliases
# =========================================================================== #
alias la='ls -la'

# Alias g=git and add shell completion
alias g='git'
compdef g=git

# Same for vim
alias v='vim'
compdef v=vim

# json pretty printing
alias jsonpp='python -mjson.tool'

# =========================================================================== #
# useful shell functions
# =========================================================================== #

# freq prints out a list of my most frequently used commands
freq() {
  cut -d" " -f1 ~/.zsh_history |
    grep -Ev "^[[:space:]]*$" |
    sort |
    uniq -c |
    sort -rn |
    head
}

# This function prints out lines in the given files that
# contain non-ascii characters
is_not_ascii() {
  if [[ "$#" == "0" ]]; then
    echo "Usage: $0 file1 file2 ..."
    return 1
  fi
  local argc="$#"
  while (("$#")); do
    if [[ "$argc" -gt "1" ]]; then echo "$1:"; fi
    perl -nwe 'print if /[^[:ascii:]]/' "$1"
    shift
  done
}

diff_line_count() {
  git diff-index --numstat HEAD
}

rand_string() {
  LANG=C LC_ALL=C tr -dc 'A-HJ-KM-NP-Za-km-np-z2-9' </dev/urandom | fold -w "${1:-32}" | head -n 1
}

ytdl() {
  local quality="bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4"
  if [[ "$1" == "--best" ]]; then
    quality="bestvideo+bestaudio"
    shift
  fi
  docker run --rm -i -v "$(pwd)":/workdir:rw mikenye/youtube-dl:latest -f "$quality" "$1"
}

# =========================================================================== #
# Tools
# =========================================================================== #

# stuff for moving around directories
# https://koenwoortman.com/zsh-cdpath/
setopt auto_cd
cdpath=($HOME $HOME/dev/artichoke $HOME/dev/hyperbola $HOME/dev/repos $HOME/dev)

if [[ -f "$HOME/.cargo/env" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
fi
