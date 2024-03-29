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
  local -r chrome_args=(
    --disable-bundled-ppapi-flash --disable-offline-load-stale-cache
    --disk-cache-size=1 --media-cache-size=1 --disk-cache-dir=/dev/null
    --no-first-run --no-referrers --no-default-browser-check
    --new-window --incognito --user-data-dir="${profile}"
  )

  open -a "Google Chrome" -nW --args "${chrome_args[@]}"

  rm -rf "${profile}"
}

# =========================================================================== #
# Programming language version managers                                       #
# =========================================================================== #

if command -v mise >/dev/null; then
  eval "$(mise activate zsh)"
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
