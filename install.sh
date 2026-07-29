#!/bin/bash

# Source required modules
source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/variables.sh"
source "$(dirname "$0")/packages.sh"
source "$(dirname "$0")/files.sh"

main() {
    # Check if the user is running as root
    check_not_root

    print_info "Welcome to your dotfiles installation script!"
    
    # 1. Install Packages
    read -p "Do you want to install packages now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_packages
    fi

    # 2. Setup Symlinks and Configs
    read -p "Do you want to setup config symlinks now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_files
    fi

    print_success "All installation steps completed! Please restart your session (Logout/Login)."
}

# Execute main function
main
