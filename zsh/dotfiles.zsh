# shellcheck shell=zsh
# vim: filetype=sh

# =========================================================================== #
# Platform-specific setup                                                     #
# =========================================================================== #

# NOTE: completions cannot be set up in the platform-specific configs since
# `compinit` hasn't been called yet.

if [[ "$OSTYPE" == darwin* ]]; then
  # shellcheck source=zsh/macos.zsh
  source "$HOME/.dotfiles/zsh/macos.zsh"
fi

# =========================================================================== #
# Shell completion                                                            #
# =========================================================================== #

autoload -Uz compinit
compinit
# Completion tools
# https://github.com/ohmyzsh/ohmyzsh/blob/a879ff1515b6bd80eea695c03e22289bd6743718/lib/completion.zsh
#
# case insensitive auto completion
# https://superuser.com/a/1092328
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

autoload -U +X bashcompinit && bashcompinit

# =========================================================================== #
# Shell history                                                               #
# =========================================================================== #

# Enable history.
# https://www.soberkoder.com/better-zsh-history/
# https://github.com/ohmyzsh/ohmyzsh/blob/a879ff1515b6bd80eea695c03e22289bd6743718/lib/history.zsh

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data between all sessions

# =========================================================================== #
# Editor, vim, aliases, completion                                            #
# =========================================================================== #

# zsh vi mode line editing
bindkey -v

export EDITOR='nvim'
alias vim='nvim'
compdef vim=nvim

# =========================================================================== #
# Aliases                                                                     #
# =========================================================================== #

alias la='ls -la'

alias g='git'
compdef g=git

# json pretty printing
alias jsonpp='python -mjson.tool'

# =========================================================================== #
# Useful shell functions                                                      #
# =========================================================================== #

# Print out a list of the most frequently used commands found in `.zsh_history`.
#
# This function takes a single optional argument for the number of top commands
# to print, which defaults to 10.
freq() {
  cut -d" " -f1 ~/.zsh_history | grep -Ev "^[[:space:]]*$" | sort | uniq -c | sort -rn | head -n"${1:-10}"
}

# Print out lines in the given files that contain either:
#
# - ASCII control bytes.
# - Non-ASCII bytes.
is_not_ascii() {
  grep -Ev '^[[:print:]]*$' "$@"
}

# Generate a random ASCII alphanumeric string.
#
# This function takes a single optional argument for the string length, which
# defaults to 32.
#
# This function omits confusables like 1, i, I, l, and L.
rand_string() {
  LANG=C LC_ALL=C tr -dc 'A-HJ-KM-NP-Za-km-np-z2-9' </dev/urandom | fold -w "${1:-32}" | head -n 1
}

# Generate a random ASCII string with only lowercase alphabetic characters.
#
# This function takes a single optional argument for the string length, which
# defaults to 16.
#
# This function omits confusables like i, l.
rand_alpha_lower() {
  LANG=C LC_ALL=C tr -dc 'a-km-np-z' </dev/urandom | fold -w "${1:-16}" | head -n 1
}

# Generate a random ASCII string with only numeric characters.
#
# This function takes a single optional argument for the string length, which
# defaults to 6.
rand_pin() {
  LANG=C LC_ALL=C tr -dc '0-9' </dev/urandom | fold -w "${1:-6}" | head -n 1
}

# Download a video using youtube-dl in a Docker container.
#
# By default, this function takes a URL to a video as its only argument. It will
# attempt to download the best quality MP4 video.
#
# If invoked as `ytdl --best URL`, this function will download the best quality
# video, but the output container is unspecified.
ytdl() {
  local quality="bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4"
  if [[ "$1" == "--best" ]]; then
    quality="bestvideo+bestaudio"
    shift
  fi
  docker run --rm -i -v "$(pwd)":/workdir:rw mikenye/youtube-dl:latest -f "$quality" "$@"
}

# =========================================================================== #
# Tools                                                                       #
# =========================================================================== #

# stuff for moving around directories
# https://koenwoortman.com/zsh-cdpath/
setopt auto_cd
cdpath=($HOME $HOME/dev/artichoke $HOME/dev/hyperbola $HOME/dev/repos $HOME/dev)

if [[ -f "$HOME/.cargo/env" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
  export CARGO_NET_GIT_FETCH_WITH_CLI=true
fi
