# https://docs.brew.sh/Shell-Completion
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

alias nosleeptillbrooklyn='caffeinate -s'
alias listening_ports='sudo lsof -PiTCP -sTCP:LISTEN'

# homebrew stuff
path+=("/usr/local/sbin" "/usr/local/bin")
export PATH

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

# rbenv on mac
export RBENV_ROOT=/usr/local/var/rbenv
if [[ ":${PATH}:" != *:"${RBENV_ROOT}/shims":* ]]; then
  eval "$(rbenv init -)"
fi

# pyenv on mac
if [[ -o login ]]; then
  export PYENV_ROOT=/usr/local/var/pyenv
  path=("$PYENV_ROOT/bin" $path)
  eval "$(pyenv init --path)"
fi

if command -v pyenv >/dev/null; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# =========================================================================== #
# Prompt
# =========================================================================== #

eval "$(starship init zsh)"
