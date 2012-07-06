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

