#!/bin/bash

# if you use public key authentication for any of these git repos,
# make sure your key doesn't have a passphrase or the fetch will
# fail

DOTFILES_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)

function update_remotes
{
  if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "update_remotes takes 1 argument (a path to a directory)"
    exit 1
  fi
  {
    pushd "$1"
    [ -d ".git" ] && git remote update
    popd
  } &> /dev/null
}

function foreach_directory
{
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "foreach_directory takes 2 arguments"
    exit 1
  fi
  if [ -d "$1" ]; then
    for dir in "$1"/*/
    do
      "$2" "$dir"
    done
  fi
}

update_remotes "$DOTFILES_ROOT"
update_remotes "$HOME/.vim"

foreach_directory "$DOTFILES_ROOT/colors" "update_remotes"
foreach_directory "$DOTFILES_ROOT/repos" "update_remotes"
foreach_directory "$DOTFILES_ROOT/vendor" "update_remotes"
