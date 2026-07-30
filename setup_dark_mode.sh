#!/bin/bash


source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/variables.sh"


setup_dark_mode() {
    print_info "Configuring system-wide Dark Mode..."

    # 1. Force dark mode via gsettings (GTK apps)
    if command -v gsettings &> /dev/null; then
        print_info "Setting GNOME/GTK dark preference..."
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' # أو الثيم المفضل لديك
    fi

    # 2. Configure GTK 3.0 settings file directly
    local gtk3_dir="$HOME/.config/gtk-3.0"
    mkdir -p "$gtk3_dir"
    
    cat << 'EOF' > "$gtk3_dir/settings.ini"
[Settings]
gtk-application-prefer-dark-theme=1
EOF
    print_success "GTK 3 dark mode configured."

    # 3. Configure GTK 4.0 settings file
    local gtk4_dir="$HOME/.config/gtk-4.0"
    mkdir -p "$gtk4_dir"
    
    cat << 'EOF' > "$gtk4_dir/settings.ini"
[Settings]
gtk-application-prefer-dark-theme=1
EOF
    print_success "GTK 4 dark mode configured."

    # 4. Environment variables for Qt / Dark theme forcing
    # Adding global dark theme flags to zsh/profile if not already present
    local profile_file="$HOME/.zshrc"
    if [ -f "$profile_file" ]; then
        if ! grep -q "QT_QPA_PLATFORMTHEME" "$profile_file"; then
            print_info "Adding Qt dark theme environment variables to .zshrc..."
            echo -e "\n# Force Dark Mode / Theming" >> "$profile_file"
            echo "export GTK_THEME=Adwaita-dark" >> "$profile_file"
            echo "export QT_QPA_PLATFORMTHEME=qt5ct" >> "$profile_file"
        fi
    fi

    print_success "Dark Mode setup completed successfully!"
}
