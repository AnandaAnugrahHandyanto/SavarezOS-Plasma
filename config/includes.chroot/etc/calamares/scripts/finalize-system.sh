#!/bin/bash
set -e

echo "[SavarezOS] Finalizing system..."

# Mount EFI if not mounted
if ! mountpoint -q /boot/efi; then
    mount /boot/efi || true
fi

# Install GRUB UEFI
echo "[SavarezOS] Installing GRUB..."

grub-install \
 --target=x86_64-efi \
 --efi-directory=/boot/efi \
 --bootloader-id=SavarezOS \
 --recheck || true

# Generate config
update-grub

# Remove installer shortcut
rm -f /home/*/Desktop/Install*.desktop
rm -f /etc/skel/Desktop/Install*.desktop

# Set SDDM theme
mkdir -p /etc/sddm.conf.d

cat <<EOF >/etc/sddm.conf.d/savarez.conf
[Theme]
Current=savarez
EOF

# Prepare SDDM theme
if [ ! -d /usr/share/sddm/themes/savarez ]; then
    cp -r /usr/share/sddm/themes/breeze /usr/share/sddm/themes/savarez
fi

# Set GRUB theme
sed -i 's|^#GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/savarez/theme.txt"|' /etc/default/grub

mkdir -p /boot/grub/themes/savarez

# Create default GRUB theme
cat <<EOF >/boot/grub/themes/savarez/theme.txt
title-text: ""
desktop-image: "background.png"
EOF

# Copy background if exists
if [ -f /usr/share/backgrounds/savarez/grub.png ]; then
    cp /usr/share/backgrounds/savarez/grub.png /boot/grub/themes/savarez/background.png
fi

update-grub

echo "[SavarezOS] Finalization complete."
