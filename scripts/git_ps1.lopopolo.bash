#!/usr/bin/env bash

unset -f git_ps1_lopopolo
git_ps1_lopopolo() {
  RED="\033[0;31m"
  GREEN="\033[0;32m"
  YELLOW="\033[0;33m"
  PLAIN="\033[m"

  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1

  if [ -z "$(GIT_REMOTES_TO_TEST_FN)" ]; then
    echo "git PS1 error: Set GIT_REMOTES_TO_TEST_FN in .bashrc"
  fi

  local git_string
  if [ -d "$(__gitdir)" ]; then
    git_string="$(__git_ps1 "%s")"
    local color
    color="$GREEN"
    git diff --ignore-submodules --no-ext-diff --quiet --exit-code || color="$YELLOW"

    # test to see if any of the given remotes exist
    local remote=""
    while read -r candidate; do
      &>/dev/null git ls-remote --exit-code . "$candidate" && remote="$candidate" && break
    done <<< "$(GIT_REMOTES_TO_TEST_FN)"

    # if one does, do an ahead-behind from it to HEAD
    local upstreamstate
    upstreamstate=""
    if [ "$remote" != "" ]; then
      local aheadbehind
      aheadbehind=$(git rev-list --quiet ${remote}...HEAD && git rev-list --count --left-right ${remote}...HEAD) # requires git 1.7.3

      local regex='([^[:space:]]+)[[:space:]]*(.*)'
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
    echo "\[$color\](${git_string}${upstreamstate}${repo_root_string})\[$PLAIN\]"
  else
    echo ""
  fi
}

unset -f ps1_help
ps1_help() {
  RED="\033[0;31m"
  GREEN="\033[0;32m"
  YELLOW="\033[0;33m"
  PLAIN="\033[m"

  echo -e "$YELLOW* means the working tree is dirty$PLAIN"
  echo -e "$GREEN+ means files are staged$PLAIN"
  echo -e "$RED% means there are untracked files$PLAIN"
  echo "upstream:"
  echo "  < means the repo is behind upstream"
  echo "  > means the repo is ahead"
  echo "  <> indicates the repo and upstream have divereged"
}

