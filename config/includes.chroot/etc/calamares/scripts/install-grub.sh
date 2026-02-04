#!/bin/bash
set -e

echo "[SavarezOS] Installing GRUB (force mode)"

TARGET="/target"

# Detect EFI partition
EFI_PART=$(lsblk -rpno NAME,PARTTYPE | grep c12a7328 | cut -d' ' -f1 | head -n1)

if [ -z "$EFI_PART" ]; then
  echo "[ERROR] No EFI partition"
  exit 1
fi

# Mount ESP into target
mkdir -p "$TARGET/boot/efi"
mount "$EFI_PART" "$TARGET/boot/efi"

# Bind system
mount --bind /dev  "$TARGET/dev"
mount --bind /proc "$TARGET/proc"
mount --bind /sys  "$TARGET/sys"

# Install grub inside target
chroot "$TARGET" grub-install \
  --target=x86_64-efi \
  --efi-directory=/boot/efi \
  --bootloader-id=SavarezOS \
  --recheck

chroot "$TARGET" update-grub

# Fallback loader
mkdir -p "$TARGET/boot/efi/EFI/BOOT"

if [ -f "$TARGET/boot/efi/EFI/SavarezOS/grubx64.efi" ]; then
  cp "$TARGET/boot/efi/EFI/SavarezOS/grubx64.efi" \
     "$TARGET/boot/efi/EFI/BOOT/BOOTX64.EFI"
fi

sync

echo "[SavarezOS] GRUB install done"
