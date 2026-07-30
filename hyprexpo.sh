#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/variables.sh"

print_info "Setting up Hyprland plugins (hyprexpo)..."

if command -v hyprpm &> /dev/null; then
    print_info "Adding hyprexpo plugin via hyprpm..."
    hyprpm add https://github.com/sandwichfarm/hyprexpo || true
    hyprpm enable hyprexpo || true
    hyprpm reload || true
    print_success "Hyprexpo plugin setup processed."
else
    print_error "hyprpm command not found!"
fi
