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
bootstrap: bundle-install sync-submodules install-oh-my-zsh
    @just stow-configs


# Installs account-specific AI tooling
setup-agents:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v claude >/dev/null; then
      echo "Installing Claude Code..."
      curl -fsSL https://claude.ai/install.sh | bash
    else
      echo "Claude Code is already installed."
    fi

    if ! command -v ocx >/dev/null; then
      echo "Installing ocx..."
      curl -fsSL https://ocx.kdco.dev/install.sh | sh
    else
      echo "ocx is already installed."
    fi

    if ! command -v claude >/dev/null; then
      echo "Skipping Claude MCP setup because Claude Code is not installed."
      exit 0
    fi

    if [ -z "${GITHUB_PAT:-}" ]; then
      echo "Skipping Claude MCP github setup because GITHUB_PAT is not set."
      exit 0
    fi

    if claude mcp list 2>/dev/null | rg '^github\b' >/dev/null; then
      echo "Claude MCP github is already configured."
      exit 0
    fi

    claude mcp add --transport http github https://api.githubcopilot.com/mcp -H "Authorization: Bearer ${GITHUB_PAT}"


# Syncs all submodules
sync-submodules:
    @git submodule update --init --recursive


# Creates symlinks in ~/.config/
stow-configs:
    @stow --restow --dotfiles --target=$HOME .


# Deletes symlinks in ~/.config/
unstow-configs:
    @stow --delete --dotfiles --target=$HOME .
