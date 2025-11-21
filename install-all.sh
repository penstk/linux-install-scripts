#!/bin/bash

# Install all packages in order
./install-zsh.sh
./install-kitty.sh
./install-tmux.sh
./install-stow.sh
./install-dotfiles.sh

./set-shell.sh
