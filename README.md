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

1. Install homebrew packages. Lists of packages can be found in `$HOME/.dotfiles/homebrew-packages`.
2. Install rubies and gems: `rbenv install $RUBY_VERSION`
3. Setup repo update cronjob located at `$HOME/.dotfiles/scripts/cron-update-remotes.bash`.

Git PS1
-------
The custom git PS1 takes a function that determine which remote to test against.
Put one in your .bashrc file.

Here is an example that includes some default remotes and chooses the current
branch if it is also a remote branch:

```bash
export git_ps1_lopopolo_remote_list='origin/master'

unset -f git_ps1_lopopolo_remote_generator
function git_ps1_lopopolo_remote_generator
{
	# if not in a git repository, do nothing
  if ! git rev-parse 2> /dev/null; then
    echo ""
    return 0
  fi
  # check that the current HEAD is a symbolic ref, i.e.: Not detached
  # and that it has a valid upstream
  if git symbolic-ref -q HEAD &>/dev/null && git rev-parse --quiet --verify '@{upstream}' &>/dev/null; then
    git rev-parse --abbrev-ref '@{upstream}'
  else
    echo "$git_ps1_lopopolo_remote_list"
  fi
}
```

ssh-agent
---------
If you wish to enable ssh agent forwarding, add the following to `.bashrc`:

```bash
# ssh-agent snippet from http://stackoverflow.com/a/18915067

SSH_ENV="$HOME/.ssh/environment"

unset -f start_agent
function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    pgrep ssh-agent | grep "${SSH_AGENT_PID}" > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi
```
