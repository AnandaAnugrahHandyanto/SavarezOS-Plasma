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

# systemd-boot entry
mkdir -p /boot/loader/entries

VMLINUX=$(ls /boot/vmlinuz-* | sort -V | tail -n1)
INITRD=$(ls /boot/initrd.img-* | sort -V | tail -n1)

VMLINUX_REL="/$(basename "$VMLINUX")"
INITRD_REL="/$(basename "$INITRD")"

ROOTUUID=$(blkid -s UUID -o value $(findmnt -n -o SOURCE /))

cat > /boot/loader/entries/savarezos.conf <<EOF
title   SavarezOS GNU/Linux
linux   $VMLINUX_REL
initrd  $INITRD_REL
options root=UUID=$ROOTUUID rw quiet splash
EOF

# rEFInd scan
ESP="/boot/efi"

mkdir -p "$ESP/EFI/Linux"

if [ -f "$ESP/EFI/SavarezOS/grubx64.efi" ]; then
  cp "$ESP/EFI/SavarezOS/grubx64.efi" \
     "$ESP/EFI/Linux/savarezos.efi"
fi

sync

echo "[SavarezOS] Finalization complete."
