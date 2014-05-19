Dotfiles
========

This is everything I want in my home directory (except my vim config, which
is in a separate repo).

Setup
-----
Bootstrapping my dotfiles doesn't make sense to me. This repo is meant to be cloned
into my `$HOME`. Git will complain if you try and clone into a non-empty directory,
which your home directory generally is. To clone:

```bash
cd $HOME
git init
git remote add origin  git@github.com:lopopolo/dotfiles.git
git pull origin master
git submodule init && git submodule update
```

Then do these things to finish setting up:

1.  Install homebrew packages. Lists of packages can be found in `$HOME/homebrew-packages`.
2.  Install rubies and gems.
  * `CONFIGURE_OPTS="--with-readline-dir=$(brew --prefix readline)" rbenv install $RUBY_VERSION`
3.  Pimp out python by installing some packages.
  *  `easy_install ipython`
  *  `easy_install readline`
  *  `easy_install pil`
4. Setup repo update cronjob located at `$HOME/scripts/cron-update-remotes.bash`.
5. Source `bashrc.lopopolo` and `bash_profile.lopopolo` from the system provided `.bashrc`
   and `.bash_profile`.
6. Symlink to the proper `.gitconfig` from `$HOME/.git-configs`.

Git PS1
-------
The custom git PS1 takes a function that determine which remote to test against.

Here is an example that includes some default remotes and chooses the current
branch if it is also a remote branch:

```bash
export GIT_REMOTES_TO_TEST='origin/master'

unset -f GIT_REMOTES_TO_TEST_FN
function GIT_REMOTES_TO_TEST_FN
{
  if [ -d "$(__gitdir)" ]; then
    # check that the current HEAD is a symbolic ref, i.e.: Not detached
    # and that it has a valid upstream
    git symbolic-ref -q HEAD &>/dev/null && \
      git rev-parse --quiet --verify @{upstream} &>/dev/null
    if [[ "$?" == "0" ]]; then
      echo "$(git rev-parse --abbrev-ref @{upstream})"
    else
      echo "$GIT_REMOTES_TO_TEST"
    fi
  else
    echo "$GIT_REMOTES_TO_TEST"
  fi
}
```

