#!/bin/bash
set -e

echo "[SavarezOS] Finalizing system..."

# Ensure EFI mounted
if ! mountpoint -q /boot/efi; then
  EFI_PART=$(lsblk -rpno NAME,PARTTYPE | grep c12a7328 | cut -d' ' -f1 | head -n1)

  if [ -n "$EFI_PART" ]; then
    mount "$EFI_PART" /boot/efi || true
  fi
fi

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

# Register in UEFI (safe)
if command -v efibootmgr >/dev/null; then

  DISK="/dev/$(lsblk -no PKNAME $(findmnt -n -o SOURCE /) | head -n1)"
  PART="$(lsblk -no PARTNUM $(findmnt -n -o SOURCE /) | head -n1)"

  if [ -n "$DISK" ] && [ -n "$PART" ]; then
    efibootmgr -c \
      -d "$DISK" \
      -p "$PART" \
      -L "SavarezOS" \
      -l '\EFI\SavarezOS\grubx64.efi' || true
  fi
fi

# rEFInd scan
ESP="/boot/efi"

mkdir -p "$ESP/EFI/Linux"

if [ -f "$ESP/EFI/SavarezOS/grubx64.efi" ]; then
  cp "$ESP/EFI/SavarezOS/grubx64.efi" \
     "$ESP/EFI/Linux/savarezos.efi"
fi

sync

echo "[SavarezOS] Finalization complete."
