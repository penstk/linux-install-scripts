#!/bin/bash

sudo pacman -S --noconfirm --needed docker docker-compose
sudo systemctl enable --now docker.service
sudo usermod -aG docker ${USER}
