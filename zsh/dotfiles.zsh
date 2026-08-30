# vim: filetype=zsh

# =========================================================================== #
# Platform-specific setup                                                     #
# =========================================================================== #

# NOTE: completions cannot be set up in the platform-specific configs since
# `compinit` hasn't been called yet.

if [[ $OSTYPE == darwin* ]]; then
  # shellcheck source=zsh/macos.zsh
  source "$HOME/.dotfiles/zsh/macos.zsh"
fi

# =========================================================================== #
# Shell completion                                                            #
# =========================================================================== #

autoload -Uz compinit
: ${ZSH_CACHE_DIR:="$HOME/.cache/zsh"}
mkdir -p "$ZSH_CACHE_DIR"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"
compinit -C -d "$ZSH_CACHE_DIR/zcompdump"
# autoload -U +X bashcompinit && bashcompinit

# =========================================================================== #
# Shell history                                                               #
# =========================================================================== #

# Enable history.
# https://www.soberkoder.com/better-zsh-history/
# https://github.com/ohmyzsh/ohmyzsh/blob/a879ff1515b6bd80eea695c03e22289bd6743718/lib/history.zsh

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_reduce_blanks     # collapse extra whitespace in commands before saving
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data between all sessions
setopt inc_append_history     # save every command to history immediately, not when the shell exits

# =========================================================================== #
# Editor, vim, aliases, completion                                            #
# =========================================================================== #

# zsh vi mode line editing
bindkey -v

export EDITOR='nvim'

alias vim='nvim'
compdef vim=nvim
alias vimdiff='nvim -d'
compdef vimdiff=nvim
alias vimtutor='nvim +Tutor'
alias g='git'
compdef g=git
alias la='ls -la'
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
  history 1 | awk '{print $2}' | awk '{count[$0]++} END {for (cmd in count) print count[cmd], cmd}' | sort -rn | head -n"${1:-10}"
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
  LANG=C LC_ALL=C tr -dc 'A-HJ-KM-NP-Za-km-np-z2-9' < /dev/urandom | fold -w "${1:-32}" | head -n 1
}

# Generate a random ASCII string with only lowercase alphabetic characters.
#
# This function takes a single optional argument for the string length, which
# defaults to 16.
#
# This function omits confusables like i, l.
rand_alpha_lower() {
  LANG=C LC_ALL=C tr -dc 'a-km-np-z' < /dev/urandom | fold -w "${1:-16}" | head -n 1
}

# Generate a random ASCII string with only numeric characters.
#
# This function takes a single optional argument for the string length, which
# defaults to 6.
rand_pin() {
  LANG=C LC_ALL=C tr -dc '0-9' < /dev/urandom | fold -w "${1:-6}" | head -n 1
}

# Download a video using yt-dlp in an Apple container.
#
# By default, this function takes a URL to a video as its only argument. It will
# attempt to download the best quality MP4 video.
#
# If invoked as `ytdl --best URL`, this function will download the best quality
# video, but the output container is unspecified.
ytdl() {
  if [ $# -eq 0 ]; then
    echo "Usage: ytdl [--best] <URL>"
    return 1
  fi

  local quality="bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4"
  if [[ $1 == "--best" ]]; then
    quality="bestvideo+bestaudio"
    shift
  fi

  if ! command -v container > /dev/null; then
    echo "ytdl: Apple container CLI is not installed"
    return 127
  fi

  local image="docker.io/jauderho/yt-dlp:latest"
  local pull_marker="${XDG_CACHE_HOME:-$HOME/.cache}/ytdl/container-image-pulled"

  container system start || return 1
  zmodload zsh/datetime
  if [[ ! -f "$pull_marker" ]] || ((EPOCHSECONDS - $(stat -f %m "$pull_marker") > 86400)); then
    mkdir -p "${pull_marker:h}"
    container image pull "$image" || return 1
    if ! container image prune > /dev/null; then
      echo "ytdl: warning: could not prune superseded container image data" >&2
    fi
    touch "$pull_marker"
  fi
  container run --rm -i --volume "$(pwd)":/downloads --workdir /downloads "$image" -f "$quality" "$@"
}

# =========================================================================== #
# Tools                                                                       #
# =========================================================================== #

setopt auto_cd
cdpath=($HOME $HOME/dev/artichoke $HOME/dev/hyperbola $HOME/dev/repos $HOME/dev)

if [[ -f "$HOME/.cargo/env" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"

  # This option tells Cargo to use the `git` binary instead of `libgit2` for git
  # operations, which is significantly faster.
  #
  # https://doc.rust-lang.org/cargo/reference/config.html#netgit-fetch-with-cli
  export CARGO_NET_GIT_FETCH_WITH_CLI=true

  # This option tells Cargo to use the HTTP-based `sparse` protocol for accessing
  # crates.io, which only downloads the necessary parts of the index and is faster.
  #
  # https://doc.rust-lang.org/cargo/reference/config.html#registriescrates-ioprotocol
  export CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
fi

# Activate mise after all other tool managers have modified PATH so its
# project-specific tool versions take precedence.
export MISE_USE_VERSIONS_HOST_TRACK=false
if command -v mise > /dev/null; then
  eval "$(mise activate zsh)"
fi
