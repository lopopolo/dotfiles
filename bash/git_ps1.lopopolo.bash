unset -f git_ps1_lopopolo
function git_ps1_lopopolo() {
  function git_ps1_lopopolo_usage() {
    echo 1>&2 -e "Example output:
$GREEN(master +ahead[1] in hyperbola-tools)$PLAIN
$YELLOW(master * in .dotfiles)$PLAIN

$YELLOW* means the working tree is dirty$PLAIN
$GREEN+ means files are staged$PLAIN

upstream:
  ahead[N]  means the repo is ahead upstream N commits
  behind[N] means the repo is behind upstream N commits"
  }

  local OPTIND opt
  while getopts ":h" opt; do
    case "$opt" in
      h)
        git_ps1_lopopolo_usage
        return 0
        ;;
      *)
        git_ps1_lopopolo_usage
        return 1
        ;;
    esac
  done
  shift $((OPTIND - 1))

  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1
  export GIT_PS1_SHOWUPSTREAM=1
  export GIT_PS1_SHOWCOLORHINTS=1

  local -r git_string="$(__git_ps1 "(%s)")"
  if [[ -z "$git_string" ]]; then
    echo ""
    return 0
  fi

  local color
  color="$GREEN"
  if ! git diff --ignore-submodules --no-ext-diff --quiet --exit-code; then
    color="$YELLOW"
  fi

  # and we're done
  echo "${color}${git_string}${PLAIN}"
}
