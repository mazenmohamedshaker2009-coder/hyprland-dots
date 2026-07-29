#!/bin/bash

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/variables.sh"

install_packages() {
    print_info "Updating system and installing packages..."

    if [ ! -f "$PACKAGES_FILE" ]; then
        print_error "Packages file (packages.txt) not found!"
        return 1
    fi

    # Update system packages
    sudo pacman -Syu --noconfirm

    # Read packages file line by line and install missing ones
    while IFS= read -r pkg; do
        [[ "$pkg" =~ ^#.*$ ]] || [[ -z "$pkg" ]] && continue
        
        if pacman -Qi "$pkg" &> /dev/null; then
            print_info "Package already installed: $pkg"
        else
            print_info "Installing: $pkg"
            sudo pacman -S --noconfirm "$pkg"
        fi
    done < "$PACKAGES_FILE"

    print_success "Packages installation completed successfully."
}
