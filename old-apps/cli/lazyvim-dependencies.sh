#!/bin/bash

# Requirements for LazyVim and friends
# Format: package:command-to-check
# If command-to-check is empty, we only check pacman.
reqs=(
  "nvim:nvim"
  "git:git"
  "lazygit:lazygit"
  "curl:curl"
  "gcc:gcc"
  "python:python"
  "python-pynvim:" # no command check
  "fzf:fzf"
  "ripgrep:rg"
  "fd:fd"
  "ttf-jetbrains-mono-nerd:" # no command check
  "nodejs:node"
  "npm:npm"
  "unzip:unzip"
)

missing_pkgs=()

for entry in "${reqs[@]}"; do
  IFS=: read -r pkg check <<<"$entry"

  # 1. Check if pacman already has this package
  if pacman -Qi "$pkg" &>/dev/null; then
    echo "[OK] $pkg already installed via pacman"
    continue
  fi

  # 2. If a command name is provided, check if it exists in PATH
  if [[ -n "$check" ]]; then
    if command -v "$check" &>/dev/null; then
      echo "[OK] Command '$check' already in PATH, skipping $pkg"
      continue
    fi
  fi

  # 3. If we get here, the requirement is missing
  echo "[MISSING] $pkg will be installed"
  missing_pkgs+=("$pkg")
done

# 4. Install all missing packages in one go
if ((${#missing_pkgs[@]} > 0)); then
  echo
  echo "Installing missing packages: ${missing_pkgs[*]}"
  sudo pacman -S --noconfirm --needed "${missing_pkgs[@]}"
else
  echo
  echo "✅ All LazyVim requirements are already satisfied."
fi
