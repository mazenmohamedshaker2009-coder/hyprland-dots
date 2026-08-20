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
    ZSH_BIN="$(command -v zsh)"
    if [ -n "$ZSH_BIN" ] && [ "$SHELL" != "$ZSH_BIN" ]; then
        print_info "Changing default shell to zsh..."
        chsh -s "$ZSH_BIN"
    else
        print_info "Default shell is already zsh."
    fi

    # 3. Install Oh My Zsh (if not already installed).
    # Prefer the vendored copy shipped in this repo (zsh/.oh-my-zsh) so the
    # install is reproducible and doesn't depend on network access; fall
    # back to the official installer if the vendored copy isn't present.
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        VENDORED_OMZ="$DOTFILES_DIR/zsh/.oh-my-zsh"
        if [ -d "$VENDORED_OMZ" ]; then
            print_info "Installing Oh My Zsh from the bundled copy in this repo..."
            cp -r "$VENDORED_OMZ" "$HOME/.oh-my-zsh"
            print_success "Oh My Zsh installed successfully (from bundled copy)."
        else
            print_info "Installing Oh My Zsh (downloading official installer)..."
            # Using RUNZSH=no and CHSH=no to prevent the installer from interrupting the script
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            print_success "Oh My Zsh installed successfully."
        fi
    else
        print_info "Oh My Zsh is already installed."
    fi

    # 4. .zshrc is installed (with backup of any existing file) by files.sh,
    # which copies zsh/.zshrc from this repo to $HOME/.zshrc. Not duplicated
    # here to avoid two competing backup/copy paths for the same file.

    print_success "Zsh setup completed!"
}
