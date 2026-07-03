BREWFILE := "Brewfile"

# List all recipes
_:
    @just --list --unsorted


# Installs Homebrew if needed
install-brew:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v brew >/dev/null || [ -x /opt/homebrew/bin/brew ] || [ -x /usr/local/bin/brew ]; then
      echo "Homebrew is already installed."
      exit 0
    fi

    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


# Installs Brewfile dependencies without upgrading existing packages
bundle-install: install-brew
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v brew >/dev/null; then
      eval "$(brew shellenv)"
    elif [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    HOMEBREW_NO_AUTO_UPDATE=1 brew bundle install --file {{BREWFILE}} --no-upgrade


# Installs agent-browser's managed browser after the npm package is present
install-agent-browser: bundle-install
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v agent-browser >/dev/null 2>&1; then
      echo "agent-browser is not installed. Run 'just bundle-install' first."
      exit 1
    fi

    agent-browser install


# Checks whether all Brewfile dependencies are installed
check-deps: install-brew
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v brew >/dev/null; then
      eval "$(brew shellenv)"
    elif [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file {{BREWFILE}} --no-upgrade


# Upgrades all Brewfile dependencies
upgrade: install-brew
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v brew >/dev/null; then
      eval "$(brew shellenv)"
    elif [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    brew bundle upgrade --file {{BREWFILE}}


# Installs Oh My Zsh without mutating the tracked .zshrc
install-oh-my-zsh:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -d "$HOME/.oh-my-zsh" ]; then
      echo "Oh My Zsh is already installed."
      exit 0
    fi

    echo "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended


# Bootstraps the local machine to the repo's declared state
bootstrap: install-agent-browser sync-submodules install-oh-my-zsh
    @just stow-configs


# Syncs all submodules
sync-submodules:
    @git submodule update --init --recursive


# Creates symlinks in ~/.config/
stow-configs:
    @stow --restow --dotfiles --target=$HOME .


# Deletes symlinks in ~/.config/
unstow-configs:
    @stow --delete --dotfiles --target=$HOME .
