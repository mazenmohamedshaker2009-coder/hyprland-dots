#!/bin/bash

# تعريف المسارات الأساسية
storage_dir="$HOME/.config/hypr/wallpapers"
storagepath="$storage_dir/.current"

# التأكد من وجود مجلد التخزين
mkdir -p "$storage_dir"

# طلب مسار الخلفية أو المجلد من المستخدم مع إمكانية استخدام Tab
read -e -p "Enter your wallpaper path or folder: " inputpath

# معالجة اختصار الـ tilde (~)
if [[ "$inputpath" == ~* ]]; then
    inputpath="${inputpath/#\~/$HOME}"
elif [[ "$inputpath" != /* ]]; then
    # إذا كنت واقفاً في نفس المجلد أو أدخلت اسماً نسبياً
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
    echo "Folder detected. Selecting a random wallpaper..."
    
    # البحث عن الصور داخل المجلد واختيار واحدة عشوائياً
    wallpath=$(find -L "$inputpath" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | shuf -n 1)
    
    if [ -z "$wallpath" ]; then
        echo "Error: No images found inside the specified folder!"
        exit 1
    fi
elif [ -f "$inputpath" ]; then
    wallpath="$inputpath"
else
    echo "Error: '$inputpath' does not exist!"
    exit 1
fi

echo "Selected wallpaper: $wallpath"

save_wall_function() {
    # ⚠️ الحل الجذري: حذف أي ملف أو مجلد قديم في مسار التخزين لضمان عدم حدوث خطأ Is a directory
    rm -rf "$storagepath"
    
    # نسخ الصورة الجديدة لتصبح هي الملف الحالي
    cp -f "$wallpath" "$storagepath"
}

apply_wall_function() {
    awww img "$storagepath" \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 1

    matugen image "$storagepath"

# 1. تحديث SwayNC بأمان (منع الملف من أن يصبح فارغاً)
    if [ -s ~/.config/swaync/style-gen.css ]; then
        cp ~/.config/swaync/style-gen.css ~/.config/swaync/style.css
        swaync-client -rs
    fi

    # 2. تحديث ألوان Kitty للنافذة الحالية والنوافذ الجديدة
    if command -v kitty &> /dev/null; then
        kitty @ --to unix:@mykitty set-colors --all ~/.config/kitty/colors.conf 2>/dev/null || true
    fi

}

save_wall_function
apply_wall_function

echo "Wallpaper applied and colors generated successfully!"
