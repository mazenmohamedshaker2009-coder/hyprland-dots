#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/variables.sh"

# Installs and configures the sddm-astronaut-theme login theme.
# Source is pinned to the upstream GitHub repository and cloned explicitly
# via git (no curl|bash, no execution of unreviewed remote scripts).
setup_sddm() {
    print_info "Setting up SDDM login theme (sddm-astronaut-theme)..."

    if ! command -v sddm &> /dev/null; then
        print_warning "sddm does not appear to be installed. Install the 'sddm' package first."
        return 1
    fi

    local theme_name="sddm-astronaut-theme"
    local theme_dest="/usr/share/sddm/themes/$theme_name"
    local repo_url="https://github.com/Keyitdev/sddm-astronaut-theme.git"

    if [ -d "$theme_dest" ]; then
        print_info "SDDM theme already installed at $theme_dest, skipping download."
    else
        local temp_dir
        temp_dir=$(mktemp -d)

        print_info "Cloning $theme_name from $repo_url..."
        if ! git clone --depth=1 "$repo_url" "$temp_dir/$theme_name"; then
            print_error "Failed to clone sddm-astronaut-theme repository."
            rm -rf "$temp_dir"
            return 1
        fi

        # Remove VCS metadata before installing system-wide
        rm -rf "${temp_dir:?}/$theme_name/.git"

        print_info "Installing theme to $theme_dest (requires sudo)..."
        if ! sudo mkdir -p "/usr/share/sddm/themes"; then
            print_error "Failed to create /usr/share/sddm/themes"
            rm -rf "$temp_dir"
            return 1
        fi

        if ! sudo cp -r "$temp_dir/$theme_name" "$theme_dest"; then
            print_error "Failed to copy theme into $theme_dest"
            rm -rf "$temp_dir"
            return 1
        fi

        # Correct ownership/permissions: theme must be readable by the sddm
        # display-manager user (runs as root), so root:root with standard
        # read/execute permissions is sufficient and matches other themes.
        sudo chown -R root:root "$theme_dest"
        sudo find "$theme_dest" -type d -exec chmod 755 {} \;
        sudo find "$theme_dest" -type f -exec chmod 644 {} \;

        rm -rf "$temp_dir"
        print_success "sddm-astronaut-theme installed to $theme_dest"
    fi

    # Configure SDDM to use the theme without clobbering unrelated settings.
    local sddm_conf_dir="/etc/sddm.conf.d"
    local sddm_theme_conf="$sddm_conf_dir/theme.conf.user"

    sudo mkdir -p "$sddm_conf_dir"

    if [ -f "$sddm_theme_conf" ] && grep -q "^Current=$theme_name$" "$sddm_theme_conf" 2>/dev/null; then
        print_info "SDDM is already configured to use $theme_name."
    else
        if [ -f "$sddm_theme_conf" ]; then
            local ts
            ts="$(date +%Y%m%d_%H%M%S)"
            print_warning "Existing $sddm_theme_conf found, backing up to ${sddm_theme_conf}.bak_$ts"
            sudo cp "$sddm_theme_conf" "${sddm_theme_conf}.bak_$ts"
        fi

        printf '[Theme]\nCurrent=%s\n' "$theme_name" | sudo tee "$sddm_theme_conf" > /dev/null
        print_success "SDDM configured to use theme: $theme_name"
    fi

    print_info "Note: some sddm-astronaut-theme variants recommend additional Qt packages"
    print_info "(qt6-multimedia, qt6-virtualkeyboard). These are listed in packages.txt."
    print_success "SDDM theme setup completed."
}
