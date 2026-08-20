#!/bin/bash


source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/variables.sh"


install_yay() {
    # Check if yay is already installed
    if command -v yay &> /dev/null; then
        print_success "yay is already installed on your system."
        return 0
    fi

    print_info "AUR Helper (yay) is required to install some necessary packages."
    
    # Request explicit confirmation from the user
    echo -ne "\n"
    read -r -p "Do you want to install 'yay' (AUR helper) now? (y/N): " yay_choice
    case "$yay_choice" in
        [yY][eE][sS]|[yY])
            print_info "Proceeding with yay installation..."
            
            # Automatically ensure essential build tools are installed to prevent makepkg errors
            print_info "Ensuring build essentials (base-devel, git) are installed..."
            if command -v pacman &> /dev/null; then
                sudo pacman -S --needed --noconfirm base-devel git
            else
                ensure_packages "base-devel" "git"
            fi

            # Create a temporary directory and clone the yay repository
            temp_dir=$(mktemp -d)
            if cd "$temp_dir"; then
                print_info "Cloning yay from AUR..."
                if git clone https://aur.archlinux.org/yay-bin.git; then
                    if cd yay-bin; then
                        print_info "Building and installing yay..."
                        if makepkg -si --noconfirm; then
                            print_success "yay installed successfully!"
                        else
                            print_error "Failed to build/install yay via makepkg."
                        fi
                    else
                        print_error "Failed to enter cloned yay-bin directory."
                    fi
                else
                    print_error "Failed to clone yay repository from AUR."
                fi
                # Clean up the temporary directory and safely return
                cd "$HOME" || true
                rm -rf "$temp_dir"
            else
                print_error "Failed to create temporary directory for yay installation."
            fi
            ;;
        *)
            print_warning "Skipping yay installation. Note: Some AUR packages might fail to install later!"
            ;;
    esac
}

# Run the function directly only if this script is executed standalone
# (not when sourced by install.sh, which prompts and calls install_yay itself).
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_yay
fi
