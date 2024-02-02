#!/bin/zsh

brew install --cask kitty
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
brew install neovim
brew tap homebrew/cask-fonts && brew install --cask font-hack-nerd-font
brew install ripgrep
