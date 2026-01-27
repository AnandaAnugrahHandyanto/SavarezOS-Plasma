#!/bin/bash
# SavarezOS Session Init

USER_HOME="$HOME"
WP="/usr/share/savarez/savarez-wallpaper.png"

# KDE wallpaper (Live + Installed)
if [ -f "$WP" ]; then
    mkdir -p "$USER_HOME/.config"

    cat > "$USER_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" <<EOF
[Containments][1]
wallpaperplugin=org.kde.image
[Containments][1][Wallpaper][org.kde.image][General]
Image=file://$WP
EOF
fi

# Remove installer shortcut after install
if [ -f /etc/savarez-installed ]; then
    rm -f "$USER_HOME/Desktop/Install-SavarezOS.desktop" 2>/dev/null
fi
