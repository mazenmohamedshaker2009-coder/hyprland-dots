#!/bin/bash

# تحديد مجلد السكربت بدقة لضمان عمل المسارات المطلقة بشكل صحيح
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# تحميل الملفات الفرعية مع التأكد من وجودها أولاً لمنع أخطاء No such file
load_module() {
    local module="$1"
    if [ -f "$SCRIPT_DIR/$module" ]; then
        source "$SCRIPT_DIR/$module"
    else
        echo "[ERROR] Required module not found: $module"
    fi
}

# Source required modules safely
load_module "utils.sh"
load_module "variables.sh"
load_module "yay.sh"
load_module "packages.sh"
load_module "files.sh"
load_module "setup_cursors.sh"
load_module "setup_dark_mode.sh"
load_module "setup_zsh.sh"
load_module "hyprexpo.sh"

main() {
    # Check if the user is running as root
    if command -v check_not_root &> /dev/null; then
        check_not_root
    fi

    print_info "Welcome to your dotfiles installation script!"
    
    # 1. Install AUR Helper (yay)
    read -p "Do you want to install yay (AUR helper) now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if declare -f install_yay > /dev/null; then
            install_yay
        else
            print_error "install_yay function not found!"
        fi
    fi

    # 2. Install Packages
    read -p "Do you want to install packages now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if declare -f install_packages > /dev/null; then
            install_packages
        else
            print_error "install_packages function not found!"
        fi
    fi

    # 3. Setup Symlinks and Configs
    read -p "Do you want to setup config files now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if declare -f setup_files > /dev/null; then
            setup_files
        else
            print_error "setup_files function not found!"
        fi
    fi

    # 4. Setup Cursor Theme (Online)
    read -p "Do you want to setup the cursor theme (Bibata-Modern-Ice) now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if declare -f setup_cursors > /dev/null; then
            setup_cursors
        else
            print_error "setup_cursors function not found!"
        fi
    fi

    # 5. Setup System-wide Dark Mode
    read -p "Do you want to configure system-wide Dark Mode now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if declare -f setup_dark_mode > /dev/null; then
            setup_dark_mode
        else
            print_error "setup_dark_mode function not found!"
        fi
    fi

    # 6. Setup Zsh and Oh-My-Zsh
    read -p "Do you want to setup Zsh and Oh-My-Zsh now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if declare -f setup_zsh > /dev/null; then
            setup_zsh
        else
            print_error "setup_zsh function not found!"
        fi
    fi

    # 7. Setup Hyprland Plugins (hyprexpo)
    read -p "Do you want to setup Hyprland plugins (hyprexpo) now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if declare -f setup_hypr_plugins > /dev/null; then
            setup_hypr_plugins
        else
            print_error "setup_hypr_plugins function not found!"
        fi
    fi

    # 8. Run Final Setup (Wallpaper, Matugen, Cleanup & Reboot prompt)
    read -p "Do you want to run the final setup (Wallpaper, Matugen, Cleanup) now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Starting final setup phase..."
        if [ -f "$SCRIPT_DIR/final_setup.sh" ]; then
            bash "$SCRIPT_DIR/final_setup.sh"
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
