# shellcheck shell=bash
# vim: filetype=sh

EDITOR="$(command -v vim)"
export EDITOR

unset -f prepend_to_path
prepend_to_path() {
  if ! [[ "$PATH" =~ (^|:)${1}($|:) ]]; then
    export PATH="$1:${PATH}"
  fi
}

unset -f append_to_path
append_to_path() {
  if ! [[ "$PATH" =~ (^|:)${1}($|:) ]]; then
    export PATH="${PATH}:$1"
  fi
}

if [[ "$(uname)" == "Darwin" ]]; then
  # shellcheck source=bash/macos.bash
  source "$HOME/.dotfiles/bash/macos.bash"
fi
if [[ "$(uname)" == "Linux" ]]; then
  # shellcheck source=bash/linux.bash
  source "$HOME/.dotfiles/bash/linux.bash"
fi

export CLICOLOR=1

# bash history
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# https://news.ycombinator.com/item?id=11811272
export HISTCONTROL=ignoreboth
export HISTSIZE=""
export HISTIGNORE="ls:exit:history:[bf]g:jobs"
shopt -s histappend

# The single best bash config option of all time. Also, see .inputrc for more vi
# goodness in readline-enabled apps.
set -o vi

# =========================================================================== #
# Aliases
# =========================================================================== #
alias la='ls -la'

# and vimrc
alias vv='vim "$HOME/.vimrc"'

# Alias g=git and add bash completion
alias g='git'
__git_complete g __git_main

# Same for vim
alias v='vim'
complete -o filenames -F _filedir_xspec v

# json pretty printing
alias jsonpp='python -mjson.tool'

# =========================================================================== #
# useful shell functions
# =========================================================================== #
unset -f freq
unset -f is_not_ascii
unset -f diff_line_count
unset -f rand_string
unset -f ytld

# freq prints out a list of my most frequently used commands
freq() {
  cut -d" " -f1 ~/.bash_history |
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
# https://bosker.wordpress.com/2012/02/12/bash-scripters-beware-of-the-cdpath/
CDPATH=".:$HOME:$HOME/dev/artichoke:$HOME/dev/hyperbola:$HOME/dev/repos:$HOME/dev"

if [[ -f "$HOME/.cargo/env" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
fi
