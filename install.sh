#!/bin/bash

# Source required modules
source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/variables.sh"
source "$(dirname "$0")/packages.sh"
source "$(dirname "$0")/files.sh"
source "$(dirname "$0")/setup_cursors.sh"
source "$(dirname "$0")/setup_dark_mode.sh"
source "$(dirname "$0")/setup_zsh.sh"
source "$(dirname "$0")/hyprexpo.sh"

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
    read -p "Do you want to setup config files now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_files
    fi

    # 3. Setup Cursor Theme (Online)
    read -p "Do you want to setup the cursor theme (Bibata-Modern-Ice) now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_cursors
    fi

    # 4. Setup System-wide Dark Mode
    read -p "Do you want to configure system-wide Dark Mode now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_dark_mode
    fi

    # 5. Setup Zsh and Oh-My-Zsh
    read -p "Do you want to setup Zsh and Oh-My-Zsh now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_zsh
    fi

    # 6. Setup Hyprland Plugins (hyprexpo)
    read -p "Do you want to setup Hyprland plugins (hyprexpo) now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_hypr_plugins
    fi

    # 7. Run Final Setup (Wallpaper, Matugen, Cleanup & Reboot prompt)
    print_info "Starting final setup phase..."
    if [ -f "$(dirname "$0")/final_setup.sh" ]; then
        bash "$(dirname "$0")/final_setup.sh"
    else
        print_error "final_setup.sh not found!"
    fi
}

# Execute main function
main
