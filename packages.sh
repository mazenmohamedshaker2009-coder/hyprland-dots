#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/variables.sh"


install_packages() {
print_info "Updating system and installing packages..."

    if [ ! -f "$PACKAGES_FILE" ]; then
        print_error "Packages file (packages.txt) not found!"
        return 1
    fi

    # Update system packages using pacman
    sudo pacman -Syu --noconfirm

    # Read packages file line by line and install missing ones
    while IFS= read -r pkg; do
        # Skip empty lines and comments
        [[ "$pkg" =~ ^#.*$ ]] || [[ -z "$pkg" ]] && continue
        
        # Check if the package is already installed (works for both pacman and AUR)
        if pacman -Qi "$pkg" &> /dev/null || yay -Qi "$pkg" &> /dev/null; then
            print_info "Package already installed: $pkg"
        else
            print_info "Installing: $pkg"
            
            # Try installing with pacman first
            if sudo pacman -S --noconfirm "$pkg" &> /dev/null; then
                print_success "Successfully installed $pkg via pacman"
            else
                # If pacman fails, try installing with yay (AUR) - without sudo
                print_info "Package not found in official repos, trying AUR (yay) for: $pkg"
                if yay -S --noconfirm "$pkg"; then
                    print_success "Successfully installed $pkg via yay"
                else
                    print_error "Failed to install $pkg from both pacman and yay!"
                fi
            fi
        fi
    done < "$PACKAGES_FILE"

    print_success "Packages installation and updates completed successfully."
}
