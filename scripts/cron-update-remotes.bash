#!/bin/bash

# if you use public key authentication for any of these git repos,
# make sure your key doesn't have a passphrase or the fetch will
# fail

cd $HOME
[ -d ".git" ] && git remote update &> /dev/null

cd $HOME/.vim
[ -d ".git" ] && git remote update &> /dev/null

function update_all_repo_remotes
{
  if [ -d "$1" ]; then
    cd "$1"
    for dir in ./*/
    do
      dir=${dir%*/}
      cd "$dir"
      [ -d ".git" ] && git remote update &> /dev/null
      cd ..
    done
  fi

}

update_all_repo_remotes $HOME/repos
update_all_repo_remotes $HOME/vendor

