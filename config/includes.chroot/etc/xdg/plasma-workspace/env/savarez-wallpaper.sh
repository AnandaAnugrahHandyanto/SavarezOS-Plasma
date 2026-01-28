#!/bin/bash

WP="/usr/share/savarez/savarez-wallpaper.png"

if command -v plasma-apply-wallpaperimage >/dev/null; then
    plasma-apply-wallpaperimage "$WP" &
fi

chmod +x config/includes.chroot/etc/xdg/plasma-workspace/env/savarez-wallpaper.sh
