# Dotfiles

Configs and scripts for making a machine feel like `$HOME`.

## Setup

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
echo '. "$HOME/.bashrc"' >> $HOME/.bash_profile"
echo '. "$HOME/.bashrc.dotfiles"' >> "$HOME/.bashrc"
```

Then do these things to finish setting up:

1. Install homebrew packages. Lists of packages can be found in `$HOME/.dotfiles/homebrew-packages`.
2. Install rubies and gems: `rbenv install $RUBY_VERSION`.
3. Install pythons: `pvenv install $PYTHON_VERSION`.
