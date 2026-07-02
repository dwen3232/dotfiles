# ============================================================================
# OH-MY-ZSH CONFIGURATION
# ============================================================================

export ZSH="$HOME/.oh-my-zsh"
export REPOS="$HOME/Repositories/"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13

plugins=(git direnv)

DISABLE_AUTO_TITLE=true

source $ZSH/oh-my-zsh.sh

# Set kitty window title to tilde-shortened current directory
set_kitty_title() { print -Pn "\e]0;%~\a" }
add-zsh-hook precmd set_kitty_title

# ============================================================================
# HOMEBREW
# ============================================================================

eval "$(brew shellenv)"
# Homebrew zsh completions, including asdf, live here.
fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)

# ============================================================================
# VERSION MANAGERS
# ============================================================================

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

# Docker completions
fpath=(/Users/davidwen/.docker/completions $fpath)
autoload -Uz compinit
compinit

export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters

# ============================================================================
# PATH CONFIGURATION
# ============================================================================

export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
export PATH="$PATH:/Users/davidwen/.local/bin"
export PATH=$PATH:$HOME/.local/share/pnpm
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/davidwen/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# ============================================================================
# TOOLS CONFIGURATION
# ============================================================================

export EDITOR="/opt/homebrew/bin/nvim"
export XDG_CONFIG_HOME="$HOME/.config"
export LIBRARY_PATH="$LIBRARY_PATH:$(brew --prefix)/lib"
export DYLD_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_LIBRARY_PATH"
# Allow OpenCode to make websearch calls
export OPENCODE_ENABLE_EXA=1

if [ -f "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc" ]; then
  source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
fi

if [ -f "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc" ]; then
  source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
fi

eval "$(direnv hook zsh)"

# ============================================================================
# ALIASES
# ============================================================================

alias nv="nvim"
alias claude=~/.claude/local/claude

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

# Reassert asdf shims after per-machine config files mutate PATH.
export ASDF_DATA_DIR="$HOME/.asdf"
path=(${ASDF_DATA_DIR}/shims ${path:#${ASDF_DATA_DIR}/shims})

if [ -f "${ASDF_DATA_DIR}/plugins/golang/set-env.zsh" ]; then
  . "${ASDF_DATA_DIR}/plugins/golang/set-env.zsh"
fi

# Bypass the asdf-nodejs shims that mis-handle `nodejs system`.
for system_node_bin in npm npx corepack; do
  if [ -x "/opt/homebrew/bin/${system_node_bin}" ]; then
    alias ${system_node_bin}="/opt/homebrew/bin/${system_node_bin}"
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
