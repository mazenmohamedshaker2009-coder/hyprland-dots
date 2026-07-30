#!/bin/bash

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/variables.sh"

setup_hypr_plugins() {
    print_info "Configuring Hyprland plugins (hyprexpo)..."

    # 1. Check if hyprpm is available
    if ! command -v hyprpm &> /dev/null; then
        print_error "hyprpm is not found! Make sure Hyprland is installed correctly."
        return 1
    }

    # 2. Add the hyprexpo repository if not already added
    print_info "Adding hyprexpo repository via hyprpm..."
    if hyprpm list | grep -q "sandwichfarm/hyprexpo"; then
        print_info "hyprexpo repository is already added."
    else
        hyprpm add https://github.com/sandwichfarm/hyprexpo
    fi

    # 3. Update plugins tree
    print_info "Updating hyprpm plugins..."
    hyprpm update

    # 4. Enable hyprexpo plugin
    print_info "Enabling hyprexpo plugin..."
    hyprpm enable hyprexpo

    print_success "Hyprland hyprexpo plugin set up and enabled successfully!"
}
