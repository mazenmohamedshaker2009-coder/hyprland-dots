#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/variables.sh"


setup_zsh() {
    print_info "Setting up Zsh and Oh My Zsh..."

    # 1. Ensure zsh is installed
    if ! pacman -Qi zsh &> /dev/null; then
        print_info "Installing zsh..."
        sudo pacman -S --noconfirm zsh
    else
        print_info "Zsh is already installed."
    fi

    # 2. Change default shell to zsh if it isn't already
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_info "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
    else
        print_info "Default shell is already zsh."
    fi

    # 3. Install Oh My Zsh (if not already installed)
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_info "Installing Oh My Zsh..."
        # Using RUNZSH=no and CHSH=no to prevent the installer from interrupting the script
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed successfully."
    else
        print_info "Oh My Zsh is already installed."
    fi

    # 4. Copy custom .zshrc from a separate folder in your project
    # Assuming you have a variable or path like PROJECT_ROOT/zsh/zshrc or similar
    CUSTOM_ZSHRC="$PROJECT_DIR/zsh/zshrc" # يمكنك تعديل المسار حسب مجلدك المنفصل

    if [ -f "$CUSTOM_ZSHRC" ]; then
        print_info "Applying custom .zshrc configuration..."
        
        # Backup existing .zshrc if it exists and is not a symlink
        if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
            mkdir -p "$BACKUP_DIR"
            mv "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.bak"
            print_warning "Backed up existing .zshrc to backup folder."
        elif [ -L "$HOME/.zshrc" ]; then
            rm "$HOME/.zshrc"
        fi

        # Copy the custom .zshrc to home directory
        cp "$CUSTOM_ZSHRC" "$HOME/.zshrc"
        print_success "Custom .zshrc applied successfully."
    else
        print_warning "Custom zshrc file not found at $CUSTOM_ZSHRC"
    fi

    print_success "Zsh setup completed!"
}
