#!/usr/bin/env bash

unset -f git_ps1_lopopolo
git_ps1_lopopolo() {
  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1

  # export colors
  RED="\033[0;31m"
  GREEN="\033[0;32m"
  YELLOW="\033[0;33m"
  BLUE="\033[0;34m"
  WHITE="\033[0;37m"
  PLAIN="\033[m"

  local git_string
  if [ -d "$(__gitdir)" ]; then
    git_string=$(__git_ps1 "%s")
    local color
    color=$GREEN
    git diff --ignore-submodules=untracked --no-ext-diff --quiet --exit-code || color=$YELLOW

    # if there are any remotes, do ahead behind from origin/master
    local hasremote
    hasremote=1
    git ls-remote --exit-code . origin/master &> /dev/null || hasremote=0
    if (( $hasremote )); then
      local aheadbehind
      local upstreamstate
      upstreamstate=""
      aheadbehind=""
      aheadbehind=$(git rev-list --count --left-right origin/master...HEAD)

      regex='([^[:space:]]+)[[:space:]]*(.*)'
      if [[ "$aheadbehind" =~ $regex ]]; then
        [[ "${BASH_REMATCH[1]}" != "0" ]] && upstreamstate="$upstreamstate -behind[${BASH_REMATCH[1]}]"
        [[ "${BASH_REMATCH[2]}" != "0" ]] && upstreamstate="$upstreamstate +ahead[${BASH_REMATCH[2]}]"
      fi
    fi
    # and we're done
    export __lopopolo_git_string=" \[$color\]($git_string$upstreamstate)\[$PLAIN\]"
  else
    export __lopopolo_git_string=""
  fi

}

unset -f ps1_help
ps1_help() {
  echo -e "$YELLOW* means the working tree is dirty$PLAIN"
  echo -e "$GREEN+ means files are staged$PLAIN"
  echo -e "$RED% means there are untracked files$PLAIN"
  echo "upstream:"
  echo "  < means the repo is behind upstream"
  echo "  > means the repo is ahead"
  echo "  <> indicates the repo and upstream have divereged"
}

