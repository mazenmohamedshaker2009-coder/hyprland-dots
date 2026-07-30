#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/variables.sh"

setup_hypr_plugins() {
    print_info "Setting up Hyprland plugins (hyprexpo)..."
    
    # التأكد من وجود أدوات البناء اللازمة للكومبايل
    ensure_packages "base-devel" "git" "cmake" "meson" "ninja" "pkgconf"

    # التحقق مما إذا كان الريبو مضافاً مسبقاً
    print_info "Checking hyprexpo repository..."
    if hyprpm list 2>/dev/null | grep -q "hyprexpo"; then
        print_info "hyprexpo repository is already added."
    else
        print_info "Adding hyprexpo repository via hyprpm..."
        if hyprpm add https://github.com/sandwichfarm/hyprexpo; then
            print_success "hyprexpo repository added successfully."
        else
            print_error "Failed to add hyprexpo automatically via hyprpm."
            print_info "You can add it manually later using: hyprpm add https://github.com/sandwichfarm/hyprexpo"
        fi
    fi

    # تحديث شجرة الـ plugins
    print_info "Updating hyprpm plugins..."
    hyprpm update || print_error "hyprpm update had some issues, continuing..."

    # تمكين الـ Plugin
    print_info "Enabling hyprexpo plugin..."
    if hyprpm enable hyprexpo; then
        print_success "Hyprland hyprexpo plugin set up and enabled successfully!"
    else
        print_error "Could not enable hyprexpo automatically. You might need to run: hyprpm enable hyprexpo"
    fi

    # إعادة تحميل الـ plugins للتأكد من تفعيلها
    hyprpm reload || true
    
    print_success "Hyprland plugins setup completed."
}
