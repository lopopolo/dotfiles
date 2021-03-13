#!/usr/bin/env bash

if [ ! -d "$HOME/.pyenv" ] && [ -d "/usr/local/var/pyenv" ]; then
  ln -snf /usr/local/var/pyenv "$HOME/.pyenv"
fi

python_version="$(cat "$HOME/.dotfiles/files/.python-version")"
neovim_venv="neovim3"

pyenv install --skip-existing "$python_version"
pyenv virtualenv --force "$python_version" "$neovim_venv"

eval "$(pyenv init -)"

pyenv activate "$neovim_venv"
pip install --force-reinstall pynvim
pyenv which python
