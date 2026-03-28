#!/usr/bin/env bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Collecting dotfiles from current system...${NC}"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"
CONFIG_DIR="$HOME/.config"

mkdir -p "$DOTFILES_DIR"

# List of configs to collect
CONFIGS=(
    "hypr"
    "waybar"
    "kitty"
    "alacritty"
    "rofi"
    "dunst"
    "wlogout"
    "starship.toml"
)

for config in "${CONFIGS[@]}"; do
    if [ -e "$CONFIG_DIR/$config" ]; then
        echo -e "${GREEN}Copying $config...${NC}"
        
        # Remove old copy in dotfiles repo if exists
        rm -rf "$DOTFILES_DIR/$config"
        
        # Copy from system to dotfiles repo
        cp -r "$CONFIG_DIR/$config" "$DOTFILES_DIR/"
    else
        echo -e "${BLUE}Skipping $config (not found in $CONFIG_DIR)${NC}"
    fi
done

echo -e "${GREEN}Collection complete! Your dotfiles are now in $DOTFILES_DIR${NC}"
echo "You can now commit and push these to your git repository."
