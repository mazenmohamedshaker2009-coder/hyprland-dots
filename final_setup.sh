#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/variables.sh"

print_info "Running final post-installation setup..."

# ==========================================
# 1. دمج وتعديل سكربت الخلفيات والألوان
# ==========================================
storage_dir="$HOME/.config/hypr/wallpapers"
storagepath="$storage_dir/.current"
default_wallpaper="$storage_dir/default.png"

# التأكد من وجود مجلد التخزين
mkdir -p "$storage_dir"

if [ -f "$default_wallpaper" ]; then
    print_info "Wallpaper setup (Press Enter to use default or type a new path/folder):"
    
    # استخدام read مع -e و -i لتمكين التعديل وعرض المسار الافتراضي جاهزاً مع دعم Tab
    read -e -i "$default_wallpaper" -p "Enter your wallpaper path or folder: " inputpath
    inputpath="${inputpath:-$default_wallpaper}"

    # معالجة اختصار الـ tilde (~)
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

    # فحص المدخل: هل هو مجلد أم ملف؟
    if [ -d "$inputpath" ]; then
        print_info "Folder detected. Selecting a random wallpaper..."
        
        wallpath=$(find -L "$inputpath" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | shuf -n 1)
        
        if [ -z "$wallpath" ]; then
            print_error "Error: No images found inside the specified folder!"
            exit 1
        fi
    elif [ -f "$inputpath" ]; then
        wallpath="$inputpath"
    else
        print_error "Error: '$inputpath' does not exist!"
        exit 1
    }

    print_info "Selected wallpaper: $wallpath"

    # دالة حفظ الخلفية
    save_wall_function() {
        rm -rf "$storagepath"
        cp -f "$wallpath" "$storagepath"
    }

    # دالة تطبيق الخلفية وتوليد الألوان وتحديث الحزم
    apply_wall_function() {
        if command -v awww &> /dev/null; then
            awww img "$storagepath" \
                --transition-type grow \
                --transition-pos center \
                --transition-duration 1
        fi

        if command -v matugen &> /dev/null; then
            print_info "Generating system colors with matugen..."
            matugen image "$storagepath" --prefer darkness || matugen image "$storagepath" || true
        fi

        # 1. تحديث SwayNC بأمان
        if [ -s "$HOME/.config/swaync/style-gen.css" ]; then
            cp "$HOME/.config/swaync/style-gen.css" "$HOME/.config/swaync/style.css"
            swaync-client -rs || true
        fi

        # 2. تحديث ألوان Kitty
        if command -v kitty &> /dev/null; then
            kitty @ --to unix:@mykitty set-colors --all "$HOME/.config/kitty/colors.conf" 2>/dev/null || true
        fi
    }

    save_wall_function
    apply_wall_function
    print_success "Wallpaper applied and colors generated successfully!"
else
    print_warning "Default wallpaper not found at $default_wallpaper, skipping wallpaper setup."
fi

# ==========================================
# 2. إعادة تحميل إضافات Hyprland
# ==========================================
print_info "Reloading Hyprland plugins..."
if command -v hyprpm &> /dev/null; then
    hyprpm reload || true
fi

# ==========================================
# 3. حذف مجلد المشروع المؤقت
# ==========================================
print_info "Cleaning up installation files..."
project_dir="$(dirname "$(realpath "$0")")"
if [ -d "$project_dir" ] && [ "$project_dir" != "$HOME" ] && [ "$project_dir" != "/" ]; then
    rm -rf "$project_dir"
    print_success "Project directory cleaned up successfully."
fi

# ==========================================
# 4. سؤال الريبوت النهائي
# ==========================================
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
