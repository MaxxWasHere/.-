#!/usr/bin/env bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Dotfiles Installation for Arch Linux + Hyprland...${NC}"

# Ask for sudo password upfront and keep it alive to prevent multiple prompts
echo -e "${BLUE}Please enter your sudo password once. We will keep it alive during the installation.${NC}"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# 1. Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    echo -e "${RED}Error: This installer is designed for Arch Linux only.${NC}"
    exit 1
fi

# 2. Update system
echo -e "${GREEN}Updating system...${NC}"
sudo pacman -Syu --noconfirm

# 3. Install AUR helper (yay) if not installed
if ! command -v yay &> /dev/null; then
    echo -e "${GREEN}Installing yay (AUR helper)...${NC}"
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi

# 4. Install base End-4 (illogical-impulse) dotfiles
echo -e "${GREEN}Cloning and installing base End-4 dotfiles...${NC}"
END4_DIR="$HOME/dots-hyprland"
if [ ! -d "$END4_DIR" ]; then
    git clone https://github.com/end-4/dots-hyprland.git "$END4_DIR"
else
    echo -e "${BLUE}End-4 repository already exists at $END4_DIR. Pulling latest...${NC}"
    cd "$END4_DIR"
    git pull
    cd -
fi

cd "$END4_DIR"
echo -e "${BLUE}Running End-4 setup script... (Follow any prompts from their installer)${NC}"
./setup install
cd -

# 5. Install user's extra packages (fixed gvfs-thunar error)
echo -e "${GREEN}Installing your extra packages...${NC}"
PACKAGES=(
    kitty
    alacritty
    zsh
    starship
    thunar
    gvfs
    thunar-volman
    gvfs-mtp
    tumbler
    eog
    mpv
    imv
    fd
)
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

AUR_PACKAGES=(
    wlogout
)
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# 6. Apply custom mods over the End-4 base
echo -e "${GREEN}Applying your custom modifications...${NC}"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"
LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/local"
CONFIG_DIR="$HOME/.config"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Copy all collected configs, overwriting the End-4 defaults
echo -e "${BLUE}Overwriting with your custom configs...${NC}"
cp -rL "$DOTFILES_DIR/"* "$CONFIG_DIR/"

# 7. Install custom fonts and icons
echo -e "${GREEN}Installing custom fonts and icons...${NC}"
mkdir -p "$HOME/.local/share/fonts"
mkdir -p "$HOME/.local/share/icons"

if [ -d "$LOCAL_DIR/share/fonts/illogical-impulse-google-sans-flex" ]; then
    cp -r "$LOCAL_DIR/share/fonts/illogical-impulse-google-sans-flex" "$HOME/.local/share/fonts/"
    fc-cache -fv
fi

if [ -e "$LOCAL_DIR/share/icons/illogical-impulse.svg" ]; then
    cp "$LOCAL_DIR/share/icons/illogical-impulse.svg" "$HOME/.local/share/icons/"
fi

# 8. Enable services
echo -e "${GREEN}Enabling services...${NC}"
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth

echo -e "${GREEN}Installation complete! Please reboot your system.${NC}"
