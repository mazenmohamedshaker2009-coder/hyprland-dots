#!/bin/bash

wallpaper="$1"

if [[ -z "$wallpaper" ]]; then
    echo "Usage: $0 <wallpaper-path>"
    exit 1
fi

if [[ ! -f "$wallpaper" ]]; then
    echo "Wallpaper not found: $wallpaper"
    exit 1
fi

if ! awww img "$wallpaper"; then
    notify-send "Bary" "Failed to change wallpaper"
    exit 1
fi

notify-send "Bary" "Wallpaper changed"

if ! matugen image "$wallpaper" --source-color-index 0; then
    notify-send "Bary" "Failed to apply theme"
    exit 1
fi

notify-send "Bary" "Theme applied"

mkdir -p "$HOME/.config/quickshell/data"

if cp "$wallpaper" "$HOME/.config/quickshell/data/.wallpaper"; then
    notify-send "Bary" "Wallpaper backup saved successfully"
else
    notify-send "Bary" "Failed to save wallpaper backup"
    exit 1
fi
