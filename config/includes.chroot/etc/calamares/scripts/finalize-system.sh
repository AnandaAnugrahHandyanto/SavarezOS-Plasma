#!/bin/bash
set -e

echo "[SavarezOS] Finalizing system..."

# Ensure EFI mounted
if ! mountpoint -q /boot/efi; then
  EFI_PART=$(lsblk -rpno NAME,PARTTYPE | grep c12a7328 | head -n1)

  [ -n "$EFI_PART" ] && mount "$EFI_PART" /boot/efi || true
fi

# Remove installer
rm -f /home/*/Desktop/Install-SavarezOS.desktop || true
rm -f /etc/skel/Desktop/Install-SavarezOS.desktop || true
rm -f /usr/share/applications/install-savarezos.desktop || true

# SDDM Theme
mkdir -p /etc/sddm.conf.d

cat > /etc/sddm.conf.d/10-savarez.conf <<EOF
[Theme]
Current=savarez
EOF

# GRUB Theme
sed -i 's|^#GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/savarez/theme.txt"|' \
  /etc/default/grub || true

mkdir -p /boot/grub/themes/savarez

cat > /boot/grub/themes/savarez/theme.txt <<EOF
title-text: ""
desktop-image: "background.png"
EOF

[ -f /usr/share/backgrounds/savarez/grub.png ] && \
cp /usr/share/backgrounds/savarez/grub.png \
   /boot/grub/themes/savarez/background.png || true

update-grub || true

# Register GRUB in UEFI
if command -v efibootmgr >/dev/null; then

  DISK="/dev/$(lsblk -no PKNAME $(findmnt -n -o SOURCE /) | head -n1)"

  [ -n "$DISK" ] && efibootmgr -c \
    -d "$DISK" \
    -p 1 \
    -L "SavarezOS" \
    -l '\EFI\SavarezOS\grubx64.efi' || true
fi

# systemd-boot: Chainload GRUB
mkdir -p /boot/loader/entries

cat > /boot/loader/entries/savarezos.conf <<EOF
title   SavarezOS
efi     /EFI/SavarezOS/grubx64.efi
EOF

# rEFInd Fallback
ESP="/boot/efi"

mkdir -p "$ESP/EFI/Linux"

if [ -f "$ESP/EFI/SavarezOS/grubx64.efi" ]; then
  cp "$ESP/EFI/SavarezOS/grubx64.efi" \
     "$ESP/EFI/Linux/savarezos.efi"
fi

sync

echo "[SavarezOS] Finalization complete."
