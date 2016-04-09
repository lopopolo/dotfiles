unset -f git_ps1_lopopolo
function git_ps1_lopopolo
{
  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1

  if [ -z "$(GIT_REMOTES_TO_TEST_FN)" ]; then
    echo "git PS1 error: Set GIT_REMOTES_TO_TEST_FN in .bashrc"
  fi

  if [ -d "$(__gitdir)" ]; then
    local git_string="$(__git_ps1 "%s")"
    local color=""
    git diff --ignore-submodules --no-ext-diff --quiet --exit-code
    if [ $? -eq 0 ]; then
      color="$GREEN"
    else
      color="$YELLOW"
    fi

    # test to see if any of the given remotes exist
    local remote=""
    while read -r candidate; do
      &>/dev/null git ls-remote --exit-code . "$candidate"
      if [ $? -eq 0 ]; then
        remote="$candidate"
        break
      fi
    done <<< "$(GIT_REMOTES_TO_TEST_FN)"

    # if one does, do an ahead-behind from it to HEAD
    local upstreamstate=""
    if [ ! -z "$remote" ]; then
      # requires git 1.7.3
      local aheadbehind=""
      git rev-list --quiet "${remote}"...HEAD
      if [ $? -eq 0 ]; then
        aheadbehind="$(git rev-list --count --left-right "${remote}"...HEAD)"
      fi

      local regex='([^[:space:]]+)[[:space:]]*(.*)'
      if [[ "$aheadbehind" =~ $regex ]]; then
        [[ "${BASH_REMATCH[1]}" != "0" ]] && upstreamstate="$upstreamstate -behind[${BASH_REMATCH[1]}]"
        [[ "${BASH_REMATCH[2]}" != "0" ]] && upstreamstate="$upstreamstate +ahead[${BASH_REMATCH[2]}]"
      fi
    fi

    # set up repo root detection
    local repo_root="$(basename "$(dirname "$(readlink-f.sh `__gitdir`)")")"
    local repo_root_string=""
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
function ps1_help
{
  local USAGE="$YELLOW* means the working tree is dirty$PLAIN
$GREEN+ means files are staged$PLAIN
$RED% means there are untracked files$PLAIN

upstream:
  +ahead[N]  means the repo is ahead upstream N commits
  -behind[N] means the repo is behind upstream N commits"

  echo -e "$USAGE"
}

