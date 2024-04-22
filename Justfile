TPM_PATH := "$HOME/.config/tmux/plugins/tpm"

# List all recipes
default:
    @just --list

# Installs homebrew
install-brew:
    @echo "------------------------------------------"
    @echo "Checking for Homebrew installation..."
    @if ! command -v brew &>/dev/null; then \
        echo "Homebrew not found, installing..."; \
        /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
        echo "Homebrew installed successfully."; \
    else \
        echo "Homebrew is already installed!"; \
    fi

# Install brew casks
install-casks: install-brew
    @echo "------------------------------------------"
    @echo "Installing casks..."
    @brew install --cask kitty # Does this work on work laptop? If not prob not work keeping
    @brew install --cask raycast
    @brew install --cask rectangle
    @brew install --cask stats
    @brew install --cask brave-browser
    @brew install --cask spotify
    @brew install --cask marta
    @brew install --cask orbstack # Docker drop-in replacement
    @brew install --cask tomatobar
    @brew install --cask openlens
    @brew install --cask boop
    @brew install --cask basictex
    @brew install --cask obsidian
    @brew tap homebrew/cask-fonts
    @brew install --cask font-hack-nerd-font

# Install brew formulae
install-formulae: install-brew
    @echo "------------------------------------------"
    @echo "Installing formulae..."
    @brew install neovim
    @brew install tmux
    @brew install neofetch
    @brew install tree
    @brew install tree-sitter
    @brew install ripgrep
    @brew install fd
    @brew install fzf
    @brew install wget

# Install all language dependencies
install-lang-deps: install-brew
    @echo "------------------------------------------"
    @echo "Installing language dependencies..."
    @brew install gcc
    @brew install pyenv
    @brew install virtualenv
    @brew install poetry
    @brew install nodejs
    @brew install terraform
    @brew install nvm
    @brew install kubernetes-cli
    @brew install just

# Install all homebrew packages
install-all: install-lang-deps install-formulae install-casks

# Setup terminal (kitty and zsh)
setup-terminal: install-casks
    @echo "------------------------------------------"
    @echo "Setting up kitty and zsh..."
    @kitty +kitten themes --reload-in=all Catppuccin-Mocha
    @echo "Checking for Oh My Zsh installation..."
    @if [ ! -d "${HOME}/.oh-my-zsh" ]; then \
        echo "Oh My Zsh not found, installing..."; \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
        echo "Oh My Zsh installed!"; \
    else \
        echo "Oh My Zsh is already installed!"; \
    fi
    @brew install zsh-completions
    @brew install zsh-syntax-highlighting
    # Maybe I should just force myself to set this manually every time? Not a good way to check for the other two
    @if [ -z "{{env_var_or_default("ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR", "")}}" ]; then \
        echo "ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR not set, adding to .zshrc..."; \
        echo "export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters" >> ~/.zshrc; \
    fi
    @brew install zsh-autosuggestions

# Setup tmux
setup-tmux: install-formulae
    @echo "------------------------------------------"
    @echo "Setting up tmux..."
    @echo "Checking for TPM installation..."
    @if [ ! -d {{TPM_PATH}} ]; then \
        echo "TPM not found at {{TPM_PATH}}. Cloning TPM..."; \
        git clone https://github.com/tmux-plugins/tpm {{TPM_PATH}}; \
    else \
        echo "TPM is already installed."; \
    fi
    @echo "Installing missing plugins..."
    @TMUX_PLUGIN_MANAGER_PATH={{TPM_PATH}} tmux start-server \; source-file ~/.config/tmux/tmux.conf \; run-shell "{{TPM_PATH}}/bin/install_plugins"
    @echo "All missing plugins have been installed."

# Setup all tools
setup-all: setup-terminal setup-tmux
