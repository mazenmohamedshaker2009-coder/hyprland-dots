#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/variables.sh"

print_info "Running final post-installation setup..."

# ==========================================
# 1. Setup wallpaper using Bary wallpaper script
# ==========================================
storage_dir="$HOME/.config/hypr/wallpapers"
default_wallpaper="$storage_dir/default.png"

# Ensure the storage directory exists
mkdir -p "$storage_dir"

if [ -f "$default_wallpaper" ]; then
    print_info "Wallpaper setup (Press Enter to use default or type a new path/folder):"

    read -r -e -i "$default_wallpaper" -p "Enter your wallpaper path or folder: " inputpath
    inputpath="${inputpath:-$default_wallpaper}"

    # Handle tilde (~) expansion
    if [[ "$inputpath" == ~* ]]; then
        inputpath="${inputpath/#\~/$HOME}"
    elif [[ "$inputpath" != /* ]]; then
        if [ -e "$PWD/$inputpath" ]; then
            inputpath="$PWD/$inputpath"
        elif [ -e "$HOME/$inputpath" ]; then
            inputpath="$HOME/$inputpath"
        else
            inputpath="$PWD/$inputpath"
        fi
    fi

    # Check the input: folder or file
    if [ -d "$inputpath" ]; then
        print_info "Folder detected. Selecting a random wallpaper..."

        wallpath=$(find -L "$inputpath" -type f \
            \( -iname "*.jpg" \
            -o -iname "*.jpeg" \
            -o -iname "*.png" \
            -o -iname "*.webp" \
            -o -iname "*.gif" \) |
            shuf -n 1)

        if [ -z "$wallpath" ]; then
            print_error "Error: No images found inside the specified folder!"
            exit 1
        fi

    elif [ -f "$inputpath" ]; then
        wallpath="$inputpath"

    else
        print_error "Error: '$inputpath' does not exist!"
        exit 1
    fi

    print_info "Selected wallpaper: $wallpath"

    # Bary wallpaper script: applies the wallpaper via awww, generates the
    # matugen color theme, and stores a backup copy for QuickShell/Bary.
    # NOTE: this is intentionally the script under config/quickshell/scripts,
    # not modules/wallpaperSelector/link.sh (which only triggers the Bary
    # wallpaper-picker IPC dispatch and does not accept a path argument).
    BARY_WALLPAPER_SCRIPT="$HOME/.config/quickshell/scripts/set_wallpaper.sh"

    if [ -f "$BARY_WALLPAPER_SCRIPT" ]; then
        print_info "Applying wallpaper through Bary..."

        if bash "$BARY_WALLPAPER_SCRIPT" "$wallpath"; then
            print_success "Wallpaper applied and theme generated successfully!"
        else
            print_error "Bary wallpaper script failed!"
            exit 1
        fi
    else
        print_error "Bary wallpaper script not found:"
        print_error "$BARY_WALLPAPER_SCRIPT"
        exit 1
    fi

else
    print_warning "Default wallpaper not found at $default_wallpaper, skipping wallpaper setup."
fi


# ==========================================
# 2. Zsh / Oh-My-Zsh
# ==========================================
# Zsh, Oh-My-Zsh, and .zshrc are already installed and made idempotent by
# setup_zsh.sh (oh-my-zsh install) and files.sh (.zshrc copy with backup).
# Re-copying the whole zsh/ tree into $HOME here duplicated that work and
# unnecessarily wiped/rewrote arbitrary files under $HOME, so it has been
# removed in favor of that single source of truth.
print_info "Zsh setup is handled by setup_zsh.sh / files.sh; nothing further to do here."


# ==========================================
# 3. Cleanup notice
# ==========================================
# Earlier versions of this script deleted the entire project/repo directory
# automatically after installing. That is a destructive, irreversible action
# on a directory the user did not explicitly ask to remove (it may be their
# only clone, may contain uncommitted edits, etc.), so it is no longer done
# automatically. Ask explicitly and require a typed confirmation instead.
project_dir="$SCRIPT_DIR"

if [ -d "$project_dir" ] && [ "$project_dir" != "$HOME" ] && [ "$project_dir" != "/" ]; then
    echo -ne "\n"
    print_warning "This will permanently delete the dotfiles project directory:"
    print_warning "  $project_dir"
    read -r -p "Type 'delete' to remove it, or press Enter to keep it: " confirm_delete
    if [ "$confirm_delete" = "delete" ]; then
        rm -rf "${project_dir:?}"
        print_success "Project directory removed."
    else
        print_info "Keeping project directory. You can remove it manually later if desired."
    fi
fi


# ==========================================
# 4. Final reboot prompt
# ==========================================
echo -ne "\n"

read -r -t 5 -p \
    "Installation is fully completed! Do you want to reboot now? (y/N) [Auto-abort in 5s]: " \
    reboot_choice || reboot_choice="n"

case "$reboot_choice" in
    [yY][eE][sS]|[yY])
        print_info "Rebooting system..."
        sudo systemctl reboot
        ;;

    *)
        print_success "Setup finished! You can reboot manually later."
        ;;
esac
