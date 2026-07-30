#!/bin/bash

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/variables.sh"

setup_cursors() {
    print_info "Setting up cursor theme (Bibata-Modern-Ice)..."

    # Define local icons directory
    local icons_dir="$HOME/.icons"
    mkdir -p "$icons_dir"

    # Check if the cursor is already installed
    if [ -d "$icons_dir/Bibata-Modern-Ice" ]; then
        print_info "Bibata-Modern-Ice cursor is already installed."
        return 0
    fi

    # Download link for Bibata-Modern-Ice from official GitHub releases
    local cursor_tar="Bibata-Modern-Ice.tar.xz"
    local download_url="https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz"

    print_info "Downloading Bibata-Modern-Ice cursor online..."
    if curl -sL "$download_url" -o "/tmp/$cursor_tar"; then
        print_info "Extracting and installing cursor..."
        tar -xf "/tmp/$cursor_tar" -C "$icons_dir"
        rm -f "/tmp/$cursor_tar"
        print_success "Bibata-Modern-Ice cursor installed successfully."
    else
        print_error "Failed to download Bibata-Modern-Ice cursor!"
        return 1
    fi
}
