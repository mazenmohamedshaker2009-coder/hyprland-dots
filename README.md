# Hyprland Dots

A minimal, keyboard-driven Hyprland setup built for speed, simplicity, and everyday use.

> [!IMPORTANT]
> These dotfiles are built around **my personal workflow**.
>
> They are **not** a commercial project, nor are they intended to satisfy everyone's preferences.
>
> Everything here exists because it fits **my workflow**. If you enjoy using them too, that's awesome—but keep in mind these dots were made for me first.

---

# Preview

## Desktop

![Desktop](screenshots/desktop.png)

## Neovim

![Neovim](screenshots/nvim.png)

## Fastfetch

![Fastfetch](screenshots/fastfetch.png)

## Cava

![Cava](screenshots/cava.png)

## Tiling

![Tiling](screenshots/tiling.png)

## Empty Workspace

![Workspace](screenshots/workspace.png)

---

# Features

- Minimal keyboard-driven workflow
- Dynamic colors powered by Matugen
- Automatic wallpaper color generation
- **Bary** — a custom QuickShell-based UI (bar, notifications, wallpaper picker, power menu, and workspace overview) that replaces Waybar, SwayNC, Wlogout, and Hyprexpo
- Blur everywhere
- Custom Bash scripts
- Hyprlock
- Hypridle
- Built-in wallpaper manager
- Fast and lightweight
- Fully automatic installation

---

# Included Components

## Bary

Bary is this rice's custom QuickShell-based shell. It provides the bar, notifications,
wallpaper picker, power menu, and workspace overview, and is the sole UI layer —
no Waybar, SwayNC, Wlogout, or Hyprexpo are installed or required.

Bary depends on `quickshell`, `awww` (wallpaper daemon), and `matugen` (theming).

## SDDM Theme

This setup uses the excellent **Astronaut SDDM Theme**.

https://github.com/Keyitdev/sddm-astronaut-theme

The installer (`setup_sddm.sh`) clones and installs it automatically.

---

## Workspace Preview

Workspace preview is provided by Bary's built-in workspace overview module
(`bary-workspaces`), bound to **Super + Tab**. No external plugin is required.

---

## Wallpapers

A wallpaper collection is included with the dotfiles.

Default location:

```text
~/.config/hypr/wallpapers/
```

Feel free to add your own wallpapers.

---

# Wallpaper Script

The recommended way to change the wallpaper is via Bary's wallpaper picker:

```bash
bary-wallpapers
```

Under the hood this uses `~/.config/quickshell/scripts/set_wallpaper.sh`, which:

- Applies the wallpaper via `awww`.
- Regenerates Matugen colors.
- Updates the entire desktop theme.
- Saves a backup copy to `~/.config/quickshell/data/.wallpaper`.

There is no need to edit any configuration files manually.

---

# Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| **Super + Return** | Open Kitty |
| **Super + E** | Open Yazi |
| **Super + N** | Open Nautilus |
| **Super + K** | Open Bary Wallpaper Picker |
| **Super + X** | Open Bary Power Menu |
| **Super + Tab** | Bary Workspace Overview |
| **Super + Q** | Close Active Window |

---

# Packages

The installation script automatically installs the following packages.

<details>
<summary><b>Click to expand the package list</b></summary>

```text
# ==========================================
# Hyprland
# ==========================================
hyprland
hyprlock
hypridle

# ==========================================
# Bary / Quickshell
# ==========================================
quickshell
awww

# ==========================================
# Terminal
# ==========================================
kitty
zsh
neovim
yazi

# ==========================================
# File Manager
# ==========================================
nautilus

# ==========================================
# Theming
# ==========================================
matugen

# ==========================================
# System
# ==========================================
networkmanager
network-manager-applet

pipewire
wireplumber
pavucontrol

libnotify

polkit-kde-agent

xdg-desktop-portal-hyprland
xdg-desktop-portal-gtk

# ==========================================
# Utilities
# ==========================================
brightnessctl
playerctl
pamixer

wl-clipboard

grim
slurp
swappy

zsh-autosuggestions
zsh-syntax-highlighting

fastfetch
btop
cava

git
curl
wget
jq
zip
unzip

# ==========================================
# Build Tools
# ==========================================
base-devel
cmake
meson
ninja
pkgconf

# ==========================================
# Fonts
# ==========================================
noto-fonts
noto-fonts-emoji

ttf-victor-mono

ttf-iosevka-nerd

ttf-nerd-fonts-symbols-common
ttf-nerd-fonts-symbols-mono

otf-font-awesome

# ==========================================
# SDDM / Qt
# ==========================================
sddm

qt6-svg
qt6-declarative
qt6-multimedia
qt6-virtualkeyboard
qt5-quickcontrols2
```

</details>

---

# Installation

```bash
git clone https://github.com/mazenmohamedshaker2009-coder/hyprland-dots

cd hyprland-dots

chmod +x install.sh

./install.sh
```

---

# Installation Script

The installer is **fully automatic**.

It will automatically:

- Install every required package.
- Detect whether `yay` is installed.
- Install `yay` if it is missing.
- Ask for confirmation whenever necessary.
- Copy all configuration files.
- Create symbolic links (including Bary's `bary-power`, `bary-wallpapers`, `bary-workspaces` commands).
- Install and configure the SDDM login theme.
- Apply all required configuration.

When the installation finishes, the desktop is ready to use.

---

# Default Browser

Firefox is configured as the default browser.

If you prefer another browser, simply edit the configuration after installation.

---

# What Is Not Included

These dotfiles intentionally **do not** include:

- Waybar, SwayNC, Wlogout, or Hyprexpo (all replaced by Bary)
- White theme
- Rofi
- Wofi
- Any application launcher other than Bary's own modules

Bary intentionally contains only:

- Workspaces
- Date / Clock
- Notifications
- Power menu
- Wallpaper picker

Nothing more.

This setup focuses on simplicity rather than adding every possible feature.

---

# Philosophy

These dotfiles are intentionally minimal.

They are built around my own workflow rather than trying to become a universal Hyprland configuration.

If you're looking for launchers, widgets, multiple bar themes, system trays, notification centers, and endless customization, these dots probably aren't for you.

If you're looking for a fast, clean, distraction-free and keyboard-driven Hyprland setup, you might enjoy them.

---

# Repository

```text
https://github.com/mazenmohamedshaker2009-coder/hyprland-dots
```

---

Made with ❤️ by Mazen
