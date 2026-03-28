#!/usr/bin/env bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Dotfiles Installation for Arch Linux + Hyprland...${NC}"

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

# 4. Install Hyprland and essential packages
echo -e "${GREEN}Installing Hyprland and core packages...${NC}"
PACKAGES=(
    # Wayland / Hyprland
    hyprland
    hyprpaper
    hypridle
    hyprlock
    xdg-desktop-portal-hyprland
    waybar
    rofi-wayland
    dunst
    
    # Terminal & Shell
    kitty
    alacritty
    zsh
    starship
    
    # Utilities
    polkit-kde-agent
    qt5-wayland
    qt6-wayland
    grim
    slurp
    wl-clipboard
    cliphist
    network-manager-applet
    pavucontrol
    blueman
    brightnessctl
    playerctl
    dart-sass
    fd
    
    # Fonts
    ttf-jetbrains-mono-nerd
    ttf-font-awesome
    noto-fonts-emoji
    
    # File Manager & Others
    thunar
    gvfs
    gvfs-thunar
    tumbler
    eog
    mpv
    imv
)

# Install official packages
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

# Install AUR packages
AUR_PACKAGES=(
    wlogout
    swww
    wl-clip-persist
    quickshell
    matugen-bin
    # add other specific AUR packages here
)
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# 5. Backup existing configs and symlink new ones
echo -e "${GREEN}Setting up dotfiles...${NC}"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"
LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/local"
CONFIG_DIR="$HOME/.config"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# List of configs to link
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
    # Check if config exists in our dotfiles repo
    if [ -e "$DOTFILES_DIR/$config" ]; then
        echo -e "${BLUE}Linking $config...${NC}"
        
        # Backup existing config
        if [ -e "$CONFIG_DIR/$config" ] || [ -L "$CONFIG_DIR/$config" ]; then
            echo "Backing up existing $config to $config.backup"
            mv "$CONFIG_DIR/$config" "$CONFIG_DIR/${config}.backup"
        fi
        
        # Create symlink
        ln -s "$DOTFILES_DIR/$config" "$CONFIG_DIR/$config"
    else
        echo -e "${RED}Warning: $config not found in $DOTFILES_DIR${NC}"
    fi
done

# 6. Install custom fonts and icons
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

# 7. Enable services
echo -e "${GREEN}Enabling services...${NC}"
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth

echo -e "${GREEN}Installation complete! Please reboot your system.${NC}"
