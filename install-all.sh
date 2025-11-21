#!/bin/bash

# Install all packages in order
./apps/install-kitty.sh
./apps/install-lazyvim.sh
./apps/install-stow.sh
# ./apps/install-dotfiles.sh
# ./apps/install-tmux.sh
# ./apps/install-zsh.sh

./set-shell.sh
