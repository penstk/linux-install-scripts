#!/bin/bash

# Install Zsh
if ! command -v zsh &>/dev/null; then
    pacman -S --noconfirm --needed zsh
fi
