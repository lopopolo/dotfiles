Dotfiles
========

This is everything I want in my home directory (except my vim config, which
is in a separate repo).

Setup
-----
Git will complain if you try and clone into a non-empty directory, which
your home directory generally is. To clone:

1.  from $HOME, `git clone https://github.com/lopopolo/dotfiles.git`
2.  `mv dotfiles/* ~/`
3.  `find dotfiles -type f -exec mv {} ~/ \;` because globbing doesn't
match dotfiles by default.
4.  `rm -rf dotfiles`
