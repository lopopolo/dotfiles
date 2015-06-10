Dotfiles
========

This is everything I want in my home directory (except my vim config, which
is in a separate repo).

Setup
-----
`git clean` in my home directory terrifies me, so these dotfiles are scoped to a
subdirectory of `$HOME` and can bootstrap themselves by making symlinks.

```bash
cd $HOME
git clone git@github.com:lopopolo/dotfiles.git .dotfiles
cd .dotfiles
git submodule update --init
make
make git-config-<TAB> # options for work or personal

# inject bash config into system provided config files
echo "source ~/.dotfiles/bash/bash_profile.lopopolo" >> $HOME/.bash_profile
echo "source ~/.dotfiles/bash/bashrc.lopopolo" >> $HOME/.bashrc
```

Then do these things to finish setting up:

1.  Install homebrew packages. Lists of packages can be found in `$HOME/.dotfiles/homebrew-packages`.
2.  Install rubies and gems.
  * `CONFIGURE_OPTS="--with-readline-dir=$(brew --prefix readline)" rbenv install $RUBY_VERSION`
3. Setup repo update cronjob located at `$HOME/.dotfiles/scripts/cron-update-remotes.bash`.

Git PS1
-------
The custom git PS1 takes a function that determine which remote to test against.
Put one in your .bashrc file.

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

