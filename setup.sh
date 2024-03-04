#!/bin/zsh

## Useful applications
# terminal
brew install --cask kitty
kitty +kitten themes --reload-in=all Catppuccin-Mocha
# launcher (spotlight replacement)
brew install --cask raycast
# file explorer
brew install --cask marta
# window manager (can raycast replace this?)
brew install --cask rectangle
# resource statistics
brew install --cask stats
# browser
brew install --cask brave-browser
# music
brew install --cask spotify
# docker
brew install --cask docker
# dev utils (TODO: write script to build this from source?)
brew install --cask devutils

## Useful developer stuff
# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# zsh (TODO: try these out!)
brew install zsh-completions zsh-syntax-highlighting zsh-autosuggestions
# neovim
brew install neovim
# font (dependency for neovim icons)
brew tap homebrew/cask-fonts && brew install --cask font-hack-nerd-font
# dependency for telescope fzf 
brew install ripgrep
brew install fd
# terminal aesthetics
brew install neofetch
brew install tmux
brew install gcc

## Language specific stuff
# python
brew install pyenv
# javascript
brew install nodejs
