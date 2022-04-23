# shellcheck shell=bash
# vim: filetype=sh
# mac specific customizations

export PLATFORM="MAC"
export BASH_SILENCE_DEPRECATION_WARNING=1

alias ls='ls -h -F'
alias nosleeptillbrooklyn='caffeinate -s'
alias brew_bundle_install='brew bundle --file=$HOME/.dotfiles/homebrew-packages/Brewfile.`hostname -s`'
alias listening_ports='sudo lsof -PiTCP -sTCP:LISTEN'

# neovim
EDITOR='nvim'
export EDITOR
alias vim='nvim'
complete -o filenames -F _filedir_xspec vim

# VS Code
append_to_path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# homebrew stuff
prepend_to_path "/usr/local/sbin"
prepend_to_path "/usr/local/bin"

# mac bash completion is broken, but homebrew's works

if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
  # shellcheck disable=SC1091
  source "$(brew --prefix)/etc/bash_completion"
fi

# chdir to frontmost window of Finder.app
unset -f cdf
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
unset -f wipe
function wipe {
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
if shopt -q login_shell; then
  export PYENV_ROOT=/usr/local/var/pyenv
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
fi

if command -v pyenv >/dev/null; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# =========================================================================== #
# Prompt
# =========================================================================== #

eval "$(starship init bash)"
