#!/bin/bash
set -e

echo "[SavarezOS] Finalizing system..."

# Remove installer shortcut
rm -f /home/*/Desktop/Install*.desktop
rm -f /etc/skel/Desktop/Install*.desktop

# Set SDDM theme
mkdir -p /etc/sddm.conf.d

cat <<EOF >/etc/sddm.conf.d/10-savarez.conf
[Theme]
Current=savarez
EOF

# Prepare SDDM theme
if [ ! -d /usr/share/sddm/themes/savarez ]; then
    cp -r /usr/share/sddm/themes/breeze /usr/share/sddm/themes/savarez
fi

# Set GRUB theme (no reinstall GRUB)
sed -i 's|^#GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/savarez/theme.txt"|' /etc/default/grub

mkdir -p /boot/grub/themes/savarez

cat <<EOF >/boot/grub/themes/savarez/theme.txt
title-text: ""
desktop-image: "background.png"
EOF

# Copy background if exists
if [ -f /usr/share/backgrounds/savarez/grub.png ]; then
    cp /usr/share/backgrounds/savarez/grub.png /boot/grub/themes/savarez/background.png
fi

update-grub

# Ensure GRUB is default boot (safe)
if command -v efibootmgr >/dev/null 2>&1; then
    BOOTNUM=$(efibootmgr | grep SavarezOS | head -n1 | awk '{print $1}' | tr -d '*Boot')
    if [ -n "$BOOTNUM" ]; then
        efibootmgr -o "$BOOTNUM" || true
    fi
fi

echo "[SavarezOS] Finalization complete."
