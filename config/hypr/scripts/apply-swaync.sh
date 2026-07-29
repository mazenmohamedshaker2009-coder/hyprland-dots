#!/bin/bash
# تشغيل ماتوجين لتوليد الملف المؤقت
matugen image /path/to/your/wallpaper.png

# التحقق مما إذا كان الملف المؤقت الناتج يحتوي على بيانات (مش فاضي)
if [ -s ~/.config/swaync/style-gen.css ]; then
    cp ~/.config/swaync/style-gen.css ~/.config/swaync/style.css
    swaync-client -rs
fi
