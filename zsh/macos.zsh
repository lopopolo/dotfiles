# =========================================================================== #
# Homebrew setup                                                              #
# =========================================================================== #

# https://docs.brew.sh/Shell-Completion
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

path=("/usr/local/sbin" "/usr/local/bin" $path)
export PATH

# =========================================================================== #
# Useful shell functions                                                      #
# =========================================================================== #

# chdir to frontmost window of Finder.app
cdf() {
  local -r finder="$(
    osascript \
      -e 'tell application "Finder"' \
      -e 'set myname to POSIX path of (target of window 1 as alias)' \
      -e 'end tell' \
      2>/dev/null
  )"

  cd "$finder" || return 1
}

# create a temporary and ephemeral Chrome instance
wipe() {
  local -r wipeprofile="$(mktemp -d)"

  open -a "Google Chrome" -nW --args \
    --user-data-dir="$wipeprofile" --no-first-run --new-window --incognito

  rm -rf "$wipeprofile"
}

# =========================================================================== #
# Programming language version managers                                       #
# =========================================================================== #

# rbenv on macOS
export RBENV_ROOT=/usr/local/var/rbenv
if command -v rbenv >/dev/null; then
  eval "$(rbenv init -)"
fi

# pyenv on macOS
if [[ -o login ]]; then
  export PYENV_ROOT=/usr/local/var/pyenv
  if command -v pyenv >/dev/null; then
    eval "$(pyenv init --path)"
  fi
fi

if command -v pyenv >/dev/null; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# =========================================================================== #
# Tools                                                                       #
# =========================================================================== #

alias nosleeptillbrooklyn='caffeinate -s'
alias listening_ports='sudo lsof -PiTCP -sTCP:LISTEN'

# =========================================================================== #
# Prompt                                                                      #
# =========================================================================== #

eval "$(starship init zsh)"
