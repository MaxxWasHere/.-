#!/usr/bin/env bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Collecting dotfiles from current system...${NC}"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"
LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/local"
CONFIG_DIR="$HOME/.config"

mkdir -p "$DOTFILES_DIR"
mkdir -p "$LOCAL_DIR/share/fonts"
mkdir -p "$LOCAL_DIR/share/icons"

# List of configs to collect
CONFIGS=(
    "hypr"
    "quickshell"
    "illogical-impulse"
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
        
        # Copy from system to dotfiles repo (using -rL to dereference symlinks)
        cp -rL "$CONFIG_DIR/$config" "$DOTFILES_DIR/"
    else
        echo -e "${BLUE}Skipping $config (not found in $CONFIG_DIR)${NC}"
    fi
done

# Collect End-4 / Illogical Impulse specific fonts and icons if they exist
echo -e "${BLUE}Checking for custom fonts and icons...${NC}"

if [ -d "$HOME/.local/share/fonts/illogical-impulse-google-sans-flex" ]; then
    echo -e "${GREEN}Copying illogical-impulse fonts...${NC}"
    rm -rf "$LOCAL_DIR/share/fonts/illogical-impulse-google-sans-flex"
    cp -rL "$HOME/.local/share/fonts/illogical-impulse-google-sans-flex" "$LOCAL_DIR/share/fonts/"
fi

if [ -e "$HOME/.local/share/icons/illogical-impulse.svg" ]; then
    echo -e "${GREEN}Copying illogical-impulse icons...${NC}"
    cp -L "$HOME/.local/share/icons/illogical-impulse.svg" "$LOCAL_DIR/share/icons/"
fi

echo -e "${GREEN}Collection complete! Your dotfiles are now in $DOTFILES_DIR and $LOCAL_DIR${NC}"
echo "You can now commit and push these to your git repository."
