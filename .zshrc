# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export REPOS="$HOME/Repositories/"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' frequency 13

plugins=(git direnv)

source $ZSH/oh-my-zsh.sh


alias nv="nvim"

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters


autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

[[ -s "/Users/davidwen/.gvm/scripts/gvm" ]] && source "/Users/davidwen/.gvm/scripts/gvm"

complete -o nospace -C /opt/homebrew/Cellar/tfenv/3.0.0/versions/1.8.3/terraform terraform


# Needed for just autocomplete, but will pull in all of brew
# https://github.com/casey/just#shell-completion-scripts
# Init Homebrew, which adds environment variables
eval "$(brew shellenv)"
# Add Homebrew's site-functions to fpath
fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)

# Needed for autosuggestions (does compinit)
source $ZSH/oh-my-zsh.sh

export EDITOR="/opt/homebrew/bin/nvim"

# Created by `pipx` on 2024-09-07 13:53:11
export PATH="$PATH:/Users/davidwen/.local/bin"

eval "$(direnv hook zsh)"

# For imagemagick
export DYLD_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_LIBRARY_PATH"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
# pyenv virtualenv auto activate
eval "$(pyenv virtualenv-init -)"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/davidwen/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# Using this so that lazygit can read from .config/ for configurations, this might break other stuff, idk yet
export XDG_CONFIG_HOME="$HOME/.config"

# Need this for husky to find pnpm properly
export PATH=$PATH:$HOME/.local/share/pnpm

# Source all .zshrc.* files (e.g., .zshrc.work, .zshrc.personal)
for config in ~/.zshrc.*; do
  if [ -f "$config" ]; then
    echo "Sourcing $config..."
    set -a
    source "$config"
    set +a
  fi
done

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/davidwen/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions


# pnpm
export PNPM_HOME="/Users/davidwen/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

## FUNCTIONS
killport() {
    if [ -z "$1" ]; then
        echo "Usage: killport <port_number>"
        return 1
    fi

    local pids=$(lsof -ti :$1)

    if [ -z "$pids" ]; then
        echo "No process found running on port $1"
        return 1
    fi

    echo "Killing processes running on port $1: $pids"
    echo "$pids" | xargs kill -9

    if [ $? -eq 0 ]; then
        echo "Processes killed successfully"
    else
        echo "Failed to kill some processes"
        return 1
    fi
}
