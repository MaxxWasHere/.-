#!/usr/bin/env bash

set -e

REPO_URL="https://github.com/MaxxWasHere/.-.git"
DEST_DIR="$HOME/.dotfiles"

echo -e "\033[0;34m=> Cloning dotfiles repository...\033[0m"

if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing git..."
    sudo pacman -S --noconfirm git
fi

if [ -d "$DEST_DIR" ]; then
    echo "=> Directory $DEST_DIR already exists. Pulling latest changes..."
    cd "$DEST_DIR"
    git pull
else
    git clone "$REPO_URL" "$DEST_DIR"
    cd "$DEST_DIR"
fi

echo -e "\033[0;32m=> Running installer...\033[0m"
chmod +x install.sh
./install.sh
