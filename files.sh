#!/bin/bash

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/variables.sh"

setup_files() {
    print_info "Setting up configurations and symlinks..."

    # Create config and backup directories if they don't exist
    mkdir -p "$HOME/.config"
    mkdir -p "$BACKUP_DIR"

    # Create symlinks for all items inside the config folder
    for d in "$CONFIG_DIR"/*; do
        if [ -d "$d" ]; then
            target_name=$(basename "$d")
            target_path="$HOME/.config/$target_name"

            # Back up existing non-symlink configurations
            if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
                print_warning "Existing config found for $target_name, backing up..."
                mv "$target_path" "$BACKUP_DIR/"
            elif [ -L "$target_path" ]; then
                rm "$target_path"
            fi

            # Create the symlink
            ln -s "$d" "$target_path"
            print_success "Linked: $target_name"
        fi
    done

    # Link system scripts to /usr/local/bin (Requires sudo)
    print_info "Setting up system scripts..."
    
    if [ -f "$HOME/.config/hypr/scripts/wallpaper.sh" ]; then
        sudo ln -sf "$HOME/.config/hypr/scripts/wallpaper.sh" /usr/local/bin/wallpaper
    fi
    
    if [ -f "$HOME/.config/hypr/scripts/screenshot.sh" ]; then
        sudo ln -sf "$HOME/.config/hypr/scripts/screenshot.sh" /usr/local/bin/screenshot
    fi

    print_success "Files and links setup completed successfully."
}
