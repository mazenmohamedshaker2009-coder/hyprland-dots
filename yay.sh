#!/bin/bash

# استيراد الأدوات والمتغيرات المشتركة
source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/variables.sh"

install_yay() {
    # التحقق مما إذا كان yay مثبتاً مسبقاً
    if command -v yay &> /dev/null; then
        print_success "yay is already installed on your system."
        return 0
    fi

    print_info "AUR Helper (yay) is required to install some necessary packages."
    
    # طلب تأكيد صريح من المستخدم
    echo -ne "\n"
    read -p "Do you want to install 'yay' (AUR helper) now? (y/N): " yay_choice
    case "$yay_choice" in
        [yY][eE][sS]|[yY])
            print_info "Proceeding with yay installation..."
            
            # التأكد من توفر الأدوات الأساسية للبناء وجلب المساعد
            ensure_packages "base-devel" "git"

            # إنشاء مجلد مؤقت واستنساخ مستودع yay
            temp_dir=$(mktemp -d)
            if cd "$temp_dir"; then
                print_info "Cloning yay from AUR..."
                if git clone https://aur.archlinux.org/yay-bin.git; then
                    cd yay-bin
                    print_info "Building and installing yay..."
                    makepkg -si --noconfirm
                    print_success "yay installed successfully!"
                else
                    print_error "Failed to clone yay repository from AUR."
                fi
                # تنظيف المجلد المؤقت
                cd ~
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

# تشغيل الدالة مباشرة لو تم تشغيل السكربت لوحده
install_yay
