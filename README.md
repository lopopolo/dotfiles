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
4.  Remember to install rubies with `rbenv install` and install gems in each
    one with `bundle install`

