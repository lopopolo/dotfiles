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


  if [ -z "${GIT_REMOTES_TO_TEST}" ]; then
    echo "git PS1 error: Set GIT_REMOTES_TO_TEST in .bashrc"
  fi

  local git_string
  if [ -d "$(__gitdir)" ]; then
    git_string=$(__git_ps1 "%s")
    local color
    color=$GREEN
    git diff --ignore-submodules=untracked --no-ext-diff --quiet --exit-code || color=$YELLOW

    # test to see if any of the given remotes exist
    local remote=""
    while read -r remote_to_test; do
      [ $(git ls-remote . ${remote_to_test} | wc -l) != 0 ] && remote=${remote_to_test} && break
    done <<< "${GIT_REMOTES_TO_TEST}"

    # if one does, do an ahead-behind from it to HEAD
    if [ "$remote" != "" ]; then
      local aheadbehind
      local upstreamstate
      upstreamstate=""
      aheadbehind=""
      aheadbehind=$(git rev-list --count --left-right ${remote}...HEAD)

      regex='([^[:space:]]+)[[:space:]]*(.*)'
      if [[ "$aheadbehind" =~ $regex ]]; then
        [[ "${BASH_REMATCH[1]}" != "0" ]] && upstreamstate="$upstreamstate -behind[${BASH_REMATCH[1]}]"
        [[ "${BASH_REMATCH[2]}" != "0" ]] && upstreamstate="$upstreamstate +ahead[${BASH_REMATCH[2]}]"
      fi
    fi

    # set up repo root detection
    local repo_root
    local repo_root_string
    repo_root_string=""

    repo_root=$(readlink-f.sh `__gitdir`)
    repo_root=$(dirname "$repo_root")
    repo_root=$(basename "$repo_root")

    if [ ! -z "$repo_root" ]; then
      repo_root_string=" in $repo_root"
    fi
    # and we're done
    export __lopopolo_git_string=" \[$color\]($git_string$upstreamstate$repo_root_string)\[$PLAIN\]"
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

