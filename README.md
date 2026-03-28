# Maxx's Dotfiles (.-)

Automated dotfiles installation for Arch Linux and Hyprland.

## One-Line Install

Run the following command on a fresh Arch Linux installation to clone the repository and start the setup automatically:

```bash
bash <(curl -s https://raw.githubusercontent.com/MaxxWasHere/.-/main/bootstrap.sh)
```

## Manual Installation

If you prefer to clone and run it manually:

```bash
git clone https://github.com/MaxxWasHere/.-.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## Updating / Collecting

To update this repository with the latest configurations from your current system:

```bash
./collect.sh
git add .
git commit -m "Update dotfiles"
git push
```

## What's Included

- **Window Manager:** Hyprland
- **Bar:** Waybar
- **Terminal:** Kitty / Alacritty
- **App Launcher:** Rofi (Wayland)
- **Notifications:** Dunst
- **Shell:** Zsh + Starship
- **Logout Menu:** Wlogout
