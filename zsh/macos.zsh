# =========================================================================== #
# Homebrew setup                                                              #
# =========================================================================== #

# https://docs.brew.sh/Shell-Completion
if type brew &>/dev/null; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" "$fpath[@]")
fi

path=("/usr/local/sbin" "/usr/local/bin" $path)
export PATH

# =========================================================================== #
# Useful shell functions                                                      #
# =========================================================================== #

# Change the current directory to the frontmost window of Finder.app.
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

# Create a temporary and ephemeral Chrome instance.
#
# This function launches a new, separate Chrome instance with a temporary
# profile in incognito mode.
#
# This function will block until the new Chrome instance is quit.
wipe() {
  local -r profile="$(mktemp -d)"

  open -a "Google Chrome" -nW --args --user-data-dir="$profile" --no-first-run --new-window --incognito

  rm -rf "$profile"
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

# Avoid defining the `CLICOLOR` env variable to get colorized `ls` output on
# macOS. `-G` is equivalent to `CLICOLOR=1` and `--color=auto`. See `man ls`.
#
# `-h` uses human size suffixes in combination with `-l`.
# `-F` displays markers for directories for executables, directories, and
# symlinks.
alias ls="ls -G -h -F"

# =========================================================================== #
# Prompt                                                                      #
# =========================================================================== #

eval "$(starship init zsh)"
