#!/bin/bash

WP="/usr/share/savarez/savarez-wallpaper.png"

# Apply wallpaper on login
if command -v plasma-apply-wallpaperimage >/dev/null; then
    plasma-apply-wallpaperimage "$WP" || true
fi

if [ -f /etc/savarez-installed ]; then
    rm -f "$HOME/Desktop/Install-SavarezOS.desktop" 2>/dev/null
fi
