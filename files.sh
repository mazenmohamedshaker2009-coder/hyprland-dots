#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/variables.sh"

setup_files() {
    print_info "Setting up configurations and copying files..."

    # Create config and backup directories if they don't exist
    mkdir -p "$HOME/.config"
    mkdir -p "$BACKUP_DIR"

    # ==========================================
    # 1. Copy all items inside the config folder
    # ==========================================
    if [ -d "$CONFIG_DIR" ]; then
        for d in "$CONFIG_DIR"/*; do
            if [ -e "$d" ]; then
                target_name=$(basename "$d")
                target_path="$HOME/.config/$target_name"

                # Back up existing configurations
                if [ -e "$target_path" ]; then
                    print_warning "Existing config found for $target_name, backing up..."
                    rm -rf "${BACKUP_DIR:?}/$target_name"
                    mv "$target_path" "$BACKUP_DIR/"
                fi

                # Copy files/folders instead of symlinking
                cp -r "$d" "$target_path"
                print_success "Copied config: $target_name -> ~/.config/"
            fi
        done
    else
        print_warning "Config directory not found at $CONFIG_DIR"
    fi

    # ==========================================
    # 2. Copy .zshrc directly to $HOME
    # ==========================================
    ZSH_SRC_DIR="$SCRIPT_DIR/zsh"

    if [ -f "$ZSH_SRC_DIR/.zshrc" ]; then
        target_zsh="$HOME/.zshrc"

        # Back up existing .zshrc if it exists
        if [ -f "$target_zsh" ]; then
            print_warning "Existing .zshrc found in Home, backing up..."
            mkdir -p "$BACKUP_DIR/zsh"
            mv "$target_zsh" "$BACKUP_DIR/zsh/.zshrc"
        fi

        cp -f "$ZSH_SRC_DIR/.zshrc" "$target_zsh"
        print_success "Copied .zshrc -> $HOME/.zshrc"
    else
        print_warning ".zshrc not found in $ZSH_SRC_DIR"
    fi

    # ==========================================
    # 3. Link all Hyprland scripts
    # ==========================================
    print_info "Setting up and symlinking system scripts..."

    SCRIPTS_DIR="$HOME/.config/hypr/scripts"

    if [ -d "$SCRIPTS_DIR" ]; then
        for script in "$SCRIPTS_DIR"/*.sh; do
            if [ -f "$script" ]; then
                # Get script name without extension
                script_name=$(basename "$script" .sh)

                # Ensure the script is executable
                chmod +x "$script"

                # Create symlink in /usr/local/bin
                sudo ln -sf "$script" "/usr/local/bin/$script_name"

                print_success "Linked script: $script_name -> /usr/local/bin/$script_name"
            fi
        done
    else
        print_warning "Scripts directory not found at $SCRIPTS_DIR"
    fi

    # ==========================================
    # 4. Link Bary module commands
    # ==========================================
    print_info "Setting up Bary module commands..."

    BARY_MODULES_DIR="$HOME/.config/quickshell/modules"

    declare -A BARY_MODULE_LINKS=(
        ["power"]="bary-power"
        ["wallpaperSelector"]="bary-wallpapers"
        ["workSpaces"]="bary-workspaces"
        ["controll"]="bary-controll"
    )

    if [ -d "$BARY_MODULES_DIR" ]; then
        for module in "${!BARY_MODULE_LINKS[@]}"; do
            script="$BARY_MODULES_DIR/$module/link.sh"
            link_name="${BARY_MODULE_LINKS[$module]}"

            if [ -f "$script" ]; then
                chmod +x "$script"
                sudo ln -sf "$script" "/usr/local/bin/$link_name"

                print_success "Linked Bary module: $link_name -> $script"
            else
                print_warning "Bary module script not found: $script"
            fi
        done
    else
        print_warning "Bary modules directory not found at $BARY_MODULES_DIR"
    fi

    # ==========================================
    # 5. Move wallpapers to ~/Wallpapers
    # ==========================================
    print_info "Setting up wallpaper directory..."

    WALLPAPER_SOURCE="$HOME/.config/hypr/wallpapers"
    WALLPAPER_DEST="$HOME/Wallpapers"

    mkdir -p "$WALLPAPER_DEST"

    if [ -d "$WALLPAPER_SOURCE" ]; then
        wallpaper_found=false

        while IFS= read -r -d '' wallpaper; do
            filename="$(basename "$wallpaper")"
            destination="$WALLPAPER_DEST/$filename"

            # Do not overwrite an existing wallpaper
            if [ -e "$destination" ]; then
                print_warning "Wallpaper already exists, keeping destination copy: $filename"
            else
                mv "$wallpaper" "$destination"
                print_success "Moved wallpaper: $filename -> ~/Wallpapers/"
            fi

            wallpaper_found=true
        done < <(
            find "$WALLPAPER_SOURCE" -maxdepth 1 -type f \
                \( \
                    -iname "*.jpg" \
                    -o -iname "*.jpeg" \
                    -o -iname "*.png" \
                    -o -iname "*.webp" \
                    -o -iname "*.gif" \
                \) \
                -print0
        )

        if [ "$wallpaper_found" = false ]; then
            print_warning "No wallpaper files found in $WALLPAPER_SOURCE"
        fi
    else
        print_warning "Wallpaper source directory not found: $WALLPAPER_SOURCE"
    fi

    # ==========================================
    # 6. Link Bary current wallpaper to SDDM
    # ==========================================
    print_info "Setting up SDDM wallpaper..."

    BARY_CURRENT_WALLPAPER="$HOME/.config/quickshell/data/.wallpaper"
    SDDM_BACKGROUND="/usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/current.png"

    if [ -f "$BARY_CURRENT_WALLPAPER" ]; then
        SDDM_BACKGROUND_DIR="$(dirname "$SDDM_BACKGROUND")"

        if [ -d "$SDDM_BACKGROUND_DIR" ]; then
            sudo ln -sfn \
                "$BARY_CURRENT_WALLPAPER" \
                "$SDDM_BACKGROUND"

            print_success "SDDM wallpaper linked successfully."
            print_success "SDDM -> $BARY_CURRENT_WALLPAPER"
        else
            print_warning "SDDM background directory not found:"
            print_warning "$SDDM_BACKGROUND_DIR"
        fi
    else
        print_warning "Bary current wallpaper not found:"
        print_warning "$BARY_CURRENT_WALLPAPER"
        print_warning "SDDM wallpaper link will be created after Bary applies its first wallpaper."
    fi

    print_success "Files setup and scripts linking completed successfully."
}
