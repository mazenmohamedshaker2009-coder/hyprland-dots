#!/bin/bash

# استيراد الأدوات والمتغيرات المشتركة
source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/variables.sh"

print_info "Running final post-installation setup..."

# 1. تحديد مسار الخلفية الثابت
storage_dir="$HOME/.config/hypr/wallpapers"
storagepath="$storage_dir/.current"
default_wallpaper="$storage_dir/default.png"

mkdir -p "$storage_dir"

# التحقق من وجود الصورة الافتراضية
if [ -f "$default_wallpaper" ]; then
    print_info "Applying default wallpaper: $default_wallpaper"
    
    # حفظ الخلفية في ملف التشغيل الحالي
    rm -rf "$storagepath"
    cp -f "$default_wallpaper" "$storagepath"

    # تطبيق الخلفية بـ awww
    if command -v awww &> /dev/null; then
        awww img "$storagepath" \
            --transition-type grow \
            --transition-pos center \
            --transition-duration 1
    fi

    # توليد الألوان وتحديث النظام بـ matugen
    if command -v matugen &> /dev/null; then
        print_info "Generating system colors with matugen..."
        matugen image "$storagepath"
    fi
else
    print_error "Default wallpaper not found at $default_wallpaper!"
fi

# 2. تحديث وتهيئة الإشعارات (SwayNC)
print_info "Configuring and restarting notifications (SwayNC)..."
if [ -f ~/.config/swaync/style-gen.css ] && [ -s ~/.config/swaync/style-gen.css ]; then
    cp ~/.config/swaync/style-gen.css ~/.config/swaync/style.css
fi
if command -v swaync-client &> /dev/null; then
    swaync-client -rs
fi

# 3. تحديث ألوان Kitty
if command -v kitty &> /dev/null; then
    kitty @ --to unix:@mykitty set-colors --all ~/.config/kitty/colors.conf 2>/dev/null || true
fi

# 4. إعادة تحميل وتفعيل إضافات Hyprland (Plugins)
print_info "Reloading Hyprland plugins..."
if command -v hyprpm &> /dev/null; then
    hyprpm reload
fi

# 5. حذف مجلد المشروع بالكامل قبل سؤال المستخدم عن الريبوت
print_info "Cleaning up installation files..."
project_dir="$(dirname "$(realpath "$0")")"
if [ -d "$project_dir" ]; then
    rm -rf "$project_dir"
    print_success "Project directory cleaned up successfully."
fi

# 6. سؤال المستخدم الأخير عن إعادة التشغيل (Reboot)
echo -ne "\n"
read -p "Installation is fully completed! Do you want to reboot now? (y/N): " reboot_choice
case "$reboot_choice" in
    [yY][eE][sS]|[yY])
        print_info "Rebooting system..."
        systemctl reboot
        ;;
    *)
        print_success "Setup finished! You can reboot manually later."
        ;;
esac
