#!/bin/bash

# if you use public key authentication for any of these git repos,
# make sure your key doesn't have a passphrase or the fetch will
# fail

cd $HOME
[ -d ".git" ] && git remote update &> /dev/null

cd $HOME/.vim
[ -d ".git" ] && git remote update &> /dev/null

if [ -d $HOME/repos ]; then
  cd $HOME/repos
  for dir in ./*/
  do
    dir=${dir%*/}
    cd "$dir"
    [ -d ".git" ] && git remote update &> /dev/null
    cd ..
  done
fi

