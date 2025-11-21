#!/bin/bash

#######################
# Install Neovim
#######################
sudo pacman -S --noconfirm --needed nvim

#######################
# Install Lazyvim
#######################
# Backup old Neovim configs if they exist

for path in \
  "$HOME/.config/nvim" \
  "$HOME/.local/share/nvim" \
  "$HOME/.local/state/nvim" \
  "$HOME/.cache/nvim"
do
  if [ -e "$path" ]; then
    mv "$path" "$path.bak"
    echo "Backed up $path → $path.bak"
  else
    echo "No existing $path — skipping"
  fi
done

# Install LazyVim starter
git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
rm -rf "$HOME/.config/nvim/.git"
