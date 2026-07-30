#!/bin/bash

# Source required modules (وظيفتها هنا تحميل الدوال والمتغيرات فقط دون تنفيذها بشكل عشوائي)
source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/variables.sh"
source "$(dirname "$0")/yay.sh"
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
    
    # 1. Install AUR Helper (yay)
    read -p "Do you want to install yay (AUR helper) now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_yay
    fi

    # 2. Install Packages
    read -p "Do you want to install packages now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_packages
    fi

    # 3. Setup Symlinks and Configs
    read -p "Do you want to setup config files now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_files
    fi

    # 4. Setup Cursor Theme (Online)
    read -p "Do you want to setup the cursor theme (Bibata-Modern-Ice) now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_cursors
    fi

    # 5. Setup System-wide Dark Mode
    read -p "Do you want to configure system-wide Dark Mode now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_dark_mode
    fi

    # 6. Setup Zsh and Oh-My-Zsh
    read -p "Do you want to setup Zsh and Oh-My-Zsh now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_zsh
    fi

    # 7. Setup Hyprland Plugins (hyprexpo)
    read -p "Do you want to setup Hyprland plugins (hyprexpo) now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_hypr_plugins
    fi

    # 8. Run Final Setup (Wallpaper, Matugen, Cleanup & Reboot prompt)
    read -p "Do you want to run the final setup (Wallpaper, Matugen, Cleanup) now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Starting final setup phase..."
        if [ -f "$(dirname "$0")/final_setup.sh" ]; then
            bash "$(dirname "$0")/final_setup.sh"
        else
            print_error "final_setup.sh not found!"
        fi
    else
        print_info "Final setup skipped by user."
    fi

    print_success "Installation script finished!"
}

# Execute main function
main
