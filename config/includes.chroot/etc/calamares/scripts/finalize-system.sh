#!/bin/bash
set -e

echo "[SavarezOS] Finalizing system..."

# Remove installer shortcut
rm -f /home/*/Desktop/Install*.desktop || true
rm -f /etc/skel/Desktop/Install*.desktop || true

# SDDM Theme
mkdir -p /etc/sddm.conf.d

cat <<EOF >/etc/sddm.conf.d/10-savarez.conf
[Theme]
Current=savarez
EOF

# GRUB Theme
sed -i 's|^#GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/savarez/theme.txt"|' /etc/default/grub

mkdir -p /boot/grub/themes/savarez

cat <<EOF >/boot/grub/themes/savarez/theme.txt
title-text: ""
desktop-image: "background.png"
EOF

[ -f /usr/share/backgrounds/savarez/grub.png ] && \
cp /usr/share/backgrounds/savarez/grub.png /boot/grub/themes/savarez/background.png

update-grub || true

# EFI Setup
ESP="/boot/efi"

mkdir -p $ESP/EFI/Linux
mkdir -p /boot/loader/entries

# Copy GRUB EFI
if [ -f $ESP/EFI/SavarezOS/grubx64.efi ]; then
  cp $ESP/EFI/SavarezOS/grubx64.efi \
     $ESP/EFI/Linux/savarezos.efi
fi

# Detect Kernel
VMLINUX=$(ls /boot/vmlinuz-* | head -n1)
INITRD=$(ls /boot/initrd.img-* | head -n1)
ROOTUUID=$(blkid -s UUID -o value $(findmnt -n -o SOURCE /))

# Create systemd-boot Entry
cat <<EOF >/boot/loader/entries/savarezos.conf
title   SavarezOS GNU/Linux
linux   $VMLINUX
initrd  $INITRD
options root=UUID=$ROOTUUID rw quiet splash
EOF

# Set Boot Priority
if command -v efibootmgr >/dev/null; then
  ID=$(efibootmgr | grep SavarezOS | head -n1 | sed 's/Boot//;s/\*//')
  [ -n "$ID" ] && efibootmgr -o $ID || true
fi

sync

echo "[SavarezOS] Finalization complete."
