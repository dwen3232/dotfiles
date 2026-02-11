# ============================================================================
# OH-MY-ZSH CONFIGURATION
# ============================================================================

export ZSH="$HOME/.oh-my-zsh"
export REPOS="$HOME/Repositories/"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13

plugins=(git direnv)

source $ZSH/oh-my-zsh.sh

# ============================================================================
# HOMEBREW
# ============================================================================

eval "$(brew shellenv)"
fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)

# ============================================================================
# VERSION MANAGERS
# ============================================================================

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Go Version Manager
[[ -s "/Users/davidwen/.gvm/scripts/gvm" ]] && source "/Users/davidwen/.gvm/scripts/gvm"

# Python Environment Manager
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
eval "$(pyenv virtualenv-init -)"

# ============================================================================
# PACKAGE MANAGERS
# ============================================================================

# pnpm
export PNPM_HOME="/Users/davidwen/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ============================================================================
# COMPLETIONS
# ============================================================================

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
complete -o nospace -C /opt/homebrew/Cellar/tfenv/3.0.0/versions/1.8.3/terraform terraform

# Docker completions
fpath=(/Users/davidwen/.docker/completions $fpath)
autoload -Uz compinit
compinit

export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters

# ============================================================================
# PATH CONFIGURATION
# ============================================================================

export PATH="$PATH:/Users/davidwen/.local/bin"
export PATH=$PATH:$HOME/.local/share/pnpm

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/davidwen/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# ============================================================================
# TOOLS CONFIGURATION
# ============================================================================

export EDITOR="/opt/homebrew/bin/nvim"
export XDG_CONFIG_HOME="$HOME/.config"
export DYLD_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_LIBRARY_PATH"

eval "$(direnv hook zsh)"

# ============================================================================
# ALIASES
# ============================================================================

alias nv="nvim"

# ============================================================================
# EXTERNAL CONFIGURATION FILES
# ============================================================================

# Source all .zshrc.* files (e.g., .zshrc.work, .zshrc.personal)
for config in ~/.zshrc.*; do
  if [ -f "$config" ]; then
    echo "Sourcing $config..."
    set -a
    source "$config"
    set +a
  fi
done

# ============================================================================
# FUNCTIONS
# ============================================================================

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
