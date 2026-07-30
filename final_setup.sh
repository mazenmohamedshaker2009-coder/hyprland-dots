#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/variables.sh"

print_info "Running final post-installation setup..."

# 1. تشغيل والتحقق من الـ daemon الخاص بـ awww وتمرير الخلفية
storage_dir="$HOME/.config/hypr/wallpapers"
default_wallpaper="$storage_dir/default.png"

if [ -f "$default_wallpaper" ]; then
    print_info "Checking and initializing wallpaper daemon (awww)..."
    
    if command -v awww &> /dev/null; then
        if ! pgrep -x "awww" > /dev/null; then
            print_info "Starting awww daemon in the background..."
            # تشغيل الـ daemon بالطريقة الصحيحة باستخدام subcommand الـ daemon
            awww daemon &
            sleep 1
        fi

        # آلية تحقق متكررة لضمان جاهزية الـ daemon واستجابته
        max_attempts=5
        attempt=1
        daemon_ready=false

        while [ $attempt -le $max_attempts ]; do
            if awww query &> /dev/null; then
                daemon_ready=true
                break
            fi
            print_warning "Waiting for awww daemon to be ready (Attempt $attempt/$max_attempts)..."
            sleep 1
            ((attempt++))
        done

        if [ "$daemon_ready" = true ]; then
            print_info "Triggering wallpaper and passing the path automatically..."
            if command -v wallpaper &> /dev/null; then
                wallpaper <<EOF
$default_wallpaper
EOF
            else
                awww img "$default_wallpaper"
            fi
        else
            print_error "Failed to connect to awww daemon after multiple attempts."
        fi
    else
        print_warning "Command 'awww' not found in PATH."
    fi

    if command -v matugen &> /dev/null; then
        print_info "Generating system colors with matugen..."
        # تم تصحيح القيمة إلى darkness بناءً على مخرجات الخطأ في الصورة
        matugen image "$default_wallpaper" --prefer darkness || matugen image "$default_wallpaper" || true
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

# 6. سؤال الريبوت النهائي
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
