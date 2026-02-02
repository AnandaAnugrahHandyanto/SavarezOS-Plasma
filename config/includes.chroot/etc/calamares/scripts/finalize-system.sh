#!/bin/bash
set -e

echo "[SavarezOS] Finalizing system..."

# Remove installer shortcut
rm -f /home/*/Desktop/Install-SavarezOS.desktop || true
rm -f /etc/skel/Desktop/Install-SavarezOS.desktop || true
rm -f /usr/share/applications/install-savarezos.desktop || true

# SDDM
mkdir -p /etc/sddm.conf.d

cat > /etc/sddm.conf.d/10-savarez.conf <<EOF
[Theme]
Current=savarez
EOF

# GRUB THEME
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

# BOOT ENTRY
ESP="/boot/efi"

mkdir -p "$ESP/EFI/Linux"
mkdir -p /boot/loader/entries

# Copy GRUB EFI (rEFInd + fallback)
if [ -f "$ESP/EFI/SavarezOS/grubx64.efi" ]; then
  cp "$ESP/EFI/SavarezOS/grubx64.efi" \
     "$ESP/EFI/Linux/savarezos.efi"
fi

# Detect kernel (relative paths for sd-boot)
VMLINUX_REL=$(basename $(ls /boot/vmlinuz-* | head -n1))
INITRD_REL=$(basename $(ls /boot/initrd.img-* | head -n1))

ROOTUUID=$(blkid -s UUID -o value \
  $(findmnt -n -o SOURCE /))

# systemd-boot entry
cat > /boot/loader/entries/savarezos.conf <<EOF
title   SavarezOS GNU/Linux
linux   /$VMLINUX_REL
initrd  /$INITRD_REL
options root=UUID=$ROOTUUID rw quiet splash
EOF

# EFI boot priority
if command -v efibootmgr >/dev/null; then
  ID=$(efibootmgr | grep SavarezOS | head -n1 | \
       sed 's/Boot//;s/\*//')

  [ -n "$ID" ] && efibootmgr -o "$ID" || true
fi

sync

echo "[SavarezOS] Finalization complete."
