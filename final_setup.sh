#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/variables.sh"

print_info "Running final post-installation setup..."

# 1. تشغيل أمر الـ wallpaper وإرسال المسار أوتوماتيكياً للـ read عبر Here-String
storage_dir="$HOME/.config/hypr/wallpapers"
default_wallpaper="$storage_dir/default.png"

if [ -f "$default_wallpaper" ]; then
    print_info "Triggering wallpaper and passing the path automatically..."
    
    if command -v wallpaper &> /dev/null; then
        wallpaper <<EOF
$default_wallpaper
EOF
    else
        print_warning "Custom 'wallpaper' command not found in PATH yet."
    fi

    if command -v matugen &> /dev/null; then
        print_info "Generating system colors with matugen..."
        matugen image "$default_wallpaper" --prefer dark || matugen image "$default_wallpaper" || true
    fi
else
    print_error "Default wallpaper not found at $default_wallpaper!"
fi

# 2. تحديث وتهيئة الإشعارات (SwayNC)
print_info "Configuring and restarting notifications (SwayNC)..."
if [ -f "$HOME/.config/swaync/style-gen.css" ] && [ -s "$HOME/.config/swaync/style-gen.css" ]; then
    cp "$HOME/.config/swaync/style-gen.css" "$HOME/.config/swaync/style.css"
fi
if command -v swaync-client &> /dev/null; then
    swaync-client -rs || true
fi

# 3. تحديث ألوان Kitty
if command -v kitty &> /dev/null; then
    kitty @ --to unix:@mykitty set-colors --all "$HOME/.config/kitty/colors.conf" 2>/dev/null || true
fi

# 4. إعادة تحميل إضافات Hyprland
print_info "Reloading Hyprland plugins..."
if command -v hyprpm &> /dev/null; then
    hyprpm reload || true
fi

# 5. حذف مجلد المشروع المؤقت
print_info "Cleaning up installation files..."
project_dir="$(dirname "$(realpath "$0")")"
if [ -d "$project_dir" ] && [ "$project_dir" != "$HOME" ] && [ "$project_dir" != "/" ]; then
    rm -rf "$project_dir"
    print_success "Project directory cleaned up successfully."
fi

# 6. سؤال الريبوت النهائي (تم ضبطه ليكون غير تفاعلي تماماً أو يدعم الـ Default لتجنب تعليق السكربت)
echo -ne "\n"
read -t 5 -p "Installation is fully completed! Do you want to reboot now? (y/N) [Auto-abort in 5s]: " reboot_choice || reboot_choice="n"
case "$reboot_choice" in
    [yY][eE][sS]|[yY])
        print_info "Rebooting system..."
        systemctl reboot
        ;;
    *)
        print_success "Setup finished! You can reboot manually later."
        ;;
esac
