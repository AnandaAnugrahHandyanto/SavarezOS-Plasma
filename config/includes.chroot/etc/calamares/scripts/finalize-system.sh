#!/bin/bash
set -e

echo "[SavarezOS] Finalizing system..."

# Remove installer shortcut
rm -f /home/*/Desktop/Install-SavarezOS.desktop || true
rm -f /etc/skel/Desktop/Install-SavarezOS.desktop || true

# Force SDDM theme
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/10-savarez.conf <<EOF
[Theme]
Current=savarez
CursorTheme=breeze_cursors
EOF

# Setup GRUB theme
sed -i 's|^#GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/savarez/theme.txt"|' /etc/default/grub || true

mkdir -p /boot/grub/themes/savarez

cat > /boot/grub/themes/savarez/theme.txt <<EOF
title-text: ""
desktop-image: "background.png"
EOF

if [ -f /usr/share/backgrounds/savarez/grub.png ]; then
  cp /usr/share/backgrounds/savarez/grub.png /boot/grub/themes/savarez/background.png
fi

update-grub || true

# Register UEFI entry (force)
DISK=$(lsblk -rpno NAME,TYPE | grep disk | head -n1)
PART=$(lsblk -rpno NAME,PARTTYPE | grep c12a7328 | head -n1)

if [ -n "$DISK" ] && [ -n "$PART" ]; then
  efibootmgr --create \
    --disk "$DISK" \
    --part 1 \
    --label "SavarezOS" \
    --loader '\EFI\SavarezOS\grubx64.efi' || true
fi

# systemd-boot entry
if [ -d /boot/loader ]; then
  mkdir -p /boot/loader/entries
  cat > /boot/loader/entries/savarezos.conf <<EOF
title SavarezOS
efi   /EFI/SavarezOS/grubx64.efi
EOF
fi

# rEFInd compatibility
mkdir -p /boot/efi/EFI/Linux

if [ -f /boot/efi/EFI/SavarezOS/grubx64.efi ]; then
  cp /boot/efi/EFI/SavarezOS/grubx64.efi \
     /boot/efi/EFI/Linux/savarezos.efi
fi

sync

echo "[SavarezOS] Finalization done"
