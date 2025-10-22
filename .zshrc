# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export REPOS="$HOME/Repositories/"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git direnv)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias nv="nvim"
# alias sd="cd ~ && cd \$(find * -type d | fzf)"

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

# Claude Code wrapper with default parameters
cld() {
    typeset -A CLAUDE_DEFAULTS
    CLAUDE_DEFAULTS=(
        --allowed-tools "Read,Write,Edit,Bash,Grep,Glob"
        # --model "sonnet"
        # --max-tokens "4096"
    )

    local default_args=()
    for flag in ${(k)CLAUDE_DEFAULTS}; do
        local flag_present=false
        for arg in "$@"; do
            if [[ "$arg" == "$flag" ]]; then
                flag_present=true
                break
            fi
        done

        if ! $flag_present; then
            default_args+=("$flag" "${CLAUDE_DEFAULTS[$flag]}")
        fi
    done

    command claude "${default_args[@]}" "$@"
}

# pnpm
export PNPM_HOME="/Users/davidwen/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
