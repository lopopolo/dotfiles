#!/usr/bin/env bash

git_ps1_lopopolo() {
  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1
  export GIT_PS1_SHOWUPSTREAM="auto"

  # export colors
  export RED="\033[0;31m"
  export GREEN="\033[0;32m"
  export YELLOW="\033[0;33m"
  export BLUE="\033[0;34m"
  export WHITE="\033[0;37m"
  export PLAIN="\033[0;0m"

  local git_string
  git_string=$(__git_ps1 "%s")
  local color
  color=$GREEN
  git diff --ignore-submodules=untracked --no-ext-diff --quiet --exit-code || color=$YELLOW
  export __lopopolo_git_string=" $color($git_string)$PLAIN"
}

ps1_help() {
  echo -e "$YELLOW* means the working tree is dirty$PLAIN"
  echo -e "$GREEN+ means files are staged$PLAIN"
  echo -e "$RED% means there are untracked files$PLAIN"
  echo "upstream:"
  echo "  < means the repo is behind upstream"
  echo "  > means the repo is ahead"
  echo "  <> indicates the repo and upstream have divereged"
}

