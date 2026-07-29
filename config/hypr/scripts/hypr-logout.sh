#!/bin/bash

if command -v hyprshutdown >/dev/null 2>&1; then
    hyprshutdown
else
    # استخدام أمر Hyprland الكلاسيكي والمباشر للخروج فوراً
    hyprctl dispatch exit 0
fi
