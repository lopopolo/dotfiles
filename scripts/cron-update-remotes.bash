#!/bin/bash -l

cd $HOME
[ -d $(__gitdir) ] && git remote update &> /dev/null

cd $HOME/.vim
[ -d $(__gitdir) ] && git remote update &> /dev/null

if [ -d $HOME/repos ]; then
  cd $HOME/repos
  for dir in ./*/
  do
    dir=${dir%*/}
    cd "$dir"
    [ -d $(__gitdir) ] && git remote update &> /dev/null
    cd ..
  done
fi

