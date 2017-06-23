unset -f git_ps1_lopopolo
function git_ps1_lopopolo() {
  function git_ps1_lopopolo_usage() {
    echo 1>&2 -e "Example output:
$GREEN(master +ahead[1] in hyperbola-tools)$PLAIN
$YELLOW(master * in .dotfiles)$PLAIN

$YELLOW* means the working tree is dirty$PLAIN
$GREEN+ means files are staged$PLAIN
$RED% means there are untracked files$PLAIN

upstream:
  +ahead[N]  means the repo is ahead upstream N commits
  -behind[N] means the repo is behind upstream N commits

git_ps1_lopopolo requires a function be defined named
git_ps1_lopopolo_remote_generator which outputs a newline-separated
list of remotes to test for upstream divergence."
  }

  local OPTIND opt
  while getopts ":h" opt; do
    case "$opt" in
      h)
        git_ps1_lopopolo_usage
        return 0
        ;;
      *)
        echo "foo"
        git_ps1_lopopolo_usage
        return 1
        ;;
    esac
  done
  shift $((OPTIND - 1))

  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1

  if [[ "$(type -t "git_ps1_lopopolo_remote_generator")" != "function" ]]; then
    echo 1>&2 "git PS1 error: Set git_ps1_lopopolo_remote_generator in .bashrc"
  fi

  # if not in a git repository, do nothing
  if ! git rev-parse 2>/dev/null; then
    echo ""
    return 0
  fi

  local -r git_string="$(__git_ps1 "%s")"
  local color
  color="$GREEN"
  if ! git diff --ignore-submodules --no-ext-diff --quiet --exit-code; then
    color="$YELLOW"
  fi

  # test to see if any of the given remotes exist
  local remote
  while read -r candidate; do
    if git ls-remote --quiet --exit-code . "$candidate" >/dev/null; then
      remote="$candidate"
      break
    fi
  done <<<"$(git_ps1_lopopolo_remote_generator)"

  # if one does, do an ahead-behind from it to HEAD
  local upstreamstate=""
  if [ ! -z "$remote" ]; then
    # requires git 1.7.3
    local aheadbehind
    if git rev-list --quiet "${remote}"...HEAD; then
      aheadbehind="$(git rev-list --count --left-right "${remote}"...HEAD)"
    fi

    # shellcheck disable=SC2086
    set -- tombstone $aheadbehind
    shift
    [[ "$1" != "0" ]] && upstreamstate="$upstreamstate -behind[$1]"
    [[ "$2" != "0" ]] && upstreamstate="$upstreamstate -ahead[$2]"
  fi

  # set up repo root detection
  local repo_root
  repo_root="$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")"
  if [ ! -z "$repo_root" ]; then
    repo_root=" in $repo_root"
  fi
  # and we're done
  echo "\[$color\](${git_string}${upstreamstate}${repo_root})\[$PLAIN\]"
}
