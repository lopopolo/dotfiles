Dotfiles
========

This is everything I want in my home directory (except my vim config, which
is in a separate repo).

Setup
-----
Git will complain if you try and clone into a non-empty directory, which
your home directory generally is. To clone:

1.  from `$HOME`, `git init`
2.  `git remote add origin  git@github.com:lopopolo/dotfiles.git`
3.  `git pull origin master`
4.  `git submodule init && git submodule update`

Then do these things to finish setting up:

1.  `brew install bash-completion git readline tig wget pil`
2.  Remember to install rubies and gems

  * `CONFIGURE_OPTS="--with-readline-dir=/usr/local/Cellar/readline/6.2.1/" rbenv install 1.`something
  * `gem install bundle`
  * `bundle install`
  * `rbenv rehash`

3.  Pimp out python:

  *  `easy_install ipython`
  *  `easy_install readline`
  *  `easy_install pil`

