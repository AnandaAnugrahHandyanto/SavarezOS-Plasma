#!/bin/bash
set -e

echo "[SavarezOS] Finalizing system..."

# Remove installer shortcut after install
rm -f /home/*/Desktop/Install-SavarezOS.desktop || true
rm -f /etc/skel/Desktop/Install-SavarezOS.desktop || true

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

# systemd-boot compatibility
if [ -d /boot/loader ]; then
  mkdir -p /boot/efi/EFI/Linux

  if [ -f /boot/efi/EFI/SavarezOS/grubx64.efi ]; then
    cp /boot/efi/EFI/SavarezOS/grubx64.efi \
       /boot/efi/EFI/Linux/savarezos.efi
  fi

  mkdir -p /boot/loader/entries

  cat <<EOF > /boot/loader/entries/savarezos.conf
title   SavarezOS
efi     /EFI/Linux/savarezos.efi
EOF
fi

echo "[SavarezOS] Finalization complete."
