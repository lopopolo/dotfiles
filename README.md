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
echo "source ~/.dotfiles/bash/bash_profile.lopopolo" >> $HOME/.bash_profile
echo "source ~/.dotfiles/bash/bashrc.lopopolo" >> $HOME/.bashrc
```

Then do these things to finish setting up:

1. Install homebrew packages. Lists of packages can be found in `$HOME/.dotfiles/homebrew-packages`.
2. Install rubies and gems: `rbenv install $RUBY_VERSION`

## ssh-agent

If you wish to enable ssh agent forwarding, add the following to `.bashrc`:

```bash
# ssh-agent snippet from http://stackoverflow.com/a/18915067

SSH_ENV="$HOME/.ssh/environment"

unset -f start_agent
function start_agent() {
  echo "Initialising new SSH agent..."
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' >"${SSH_ENV}"
  echo succeeded
  chmod 600 "${SSH_ENV}"
  . "${SSH_ENV}" >/dev/null
  /usr/bin/ssh-add;
}

# Source SSH settings, if applicable
unset -f find_or_start_agent
function find_or_start_agent() {
  if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" >/dev/null
    pgrep ssh-agent | grep "${SSH_AGENT_PID}" >/dev/null || {
      start_agent
    }
  else
    start_agent
  fi
}

read -n 1 -s -r -p "Press any key to continue"
echo

find_or_start_agent
```
