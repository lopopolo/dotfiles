# Dotfiles

Configs and scripts for making a machine feel like `$HOME`.

## Setup

`git clean` in my home directory terrifies me, so these dotfiles are scoped to a
subdirectory of `$HOME` and can bootstrap themselves by making symlinks.

```bash
cd $HOME
git clone git@github.com:lopopolo/dotfiles.git .dotfiles
cd .dotfiles
make
make git-config-<TAB> # options for work or personal

# inject bash config into system provided config files
echo '. "$HOME/.bashrc"' >> $HOME/.bash_profile"
echo '. "$HOME/.bashrc.dotfiles"' >> "$HOME/.bashrc"
```

## Homebrew

Packages for each machine are found in [homebrew-packages](/homebrew-packages).

Install packages for the current machine using:

```bash
brew_bundle_install
```

## Languages

### ruby

```
rbenv install "$(cat $HOME/.ruby-version)"
```

### python

```
pyenv install "$(cat $HOME/.python-version)"
```
