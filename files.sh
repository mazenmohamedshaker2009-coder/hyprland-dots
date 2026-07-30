#!/bin/bash

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/variables.sh"

setup_files() {
    print_info "Setting up configurations and copying files..."

    # Create config and backup directories if they don't exist
    mkdir -p "$HOME/.config"
    mkdir -p "$BACKUP_DIR"

    # Copy all items (files and directories) inside the config folder to ~/.config/
    for d in "$CONFIG_DIR"/*; do
        if [ -e "$d" ]; then
            target_name=$(basename "$d")
            target_path="$HOME/.config/$target_name"

            # Back up existing configurations
            if [ -e "$target_path" ]; then
                print_warning "Existing config found for $target_name, backing up..."
                rm -rf "$BACKUP_DIR/$target_name"
                mv "$target_path" "$BACKUP_DIR/"
            fi

            # Copy files/folders instead of symlinking
            cp -r "$d" "$target_path"
            print_success "Copied: $target_name"
        fi
    done

    # Automatically link all scripts from ~/.config/hypr/scripts/ to /usr/local/bin (Stripping .sh)
    print_info "Setting up and symlinking system scripts..."
    
    SCRIPTS_DIR="$HOME/.config/hypr/scripts"
    
    if [ -d "$SCRIPTS_DIR" ]; then
        for script in "$SCRIPTS_DIR"/*.sh; do
            if [ -f "$script" ]; then
                # Get script name without extension (e.g., wallpaper.sh -> wallpaper)
                script_name=$(basename "$script" .sh)
                
                # Create symlink in /usr/local/bin
                sudo ln -sf "$script" "/usr/local/bin/$script_name"
                print_success "Linked script: $script_name -> /usr/local/bin/$script_name"
            fi
        done
    else
        print_warning "Scripts directory not found at $SCRIPTS_DIR"
    fi

    print_success "Files setup and scripts linking completed successfully."
}
