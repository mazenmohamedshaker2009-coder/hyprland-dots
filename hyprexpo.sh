#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

setup_hypr_plugins() {
    echo "[INFO] Starting Hyprland plugins setup..."
    
    if ! command -v hyprpm &> /dev/null; then
        echo "[ERROR] hyprpm is not installed!"
        return 1
    fi

    echo "[INFO] Running hyprpm update and adding plugins..."
    hyprpm update
    hyprpm add https://github.com/sandwichfarm/hyprexpo
    hyprpm enable hyprexpo

    echo "[SUCCESS] Hyprland plugins setup completed!"
}
