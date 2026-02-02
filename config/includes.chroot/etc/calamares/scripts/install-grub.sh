#!/bin/bash
set -e

echo "[SavarezOS] Installing GRUB (UEFI)"

TARGET="/target"
ESP="$TARGET/boot/efi"

# Detect EFI partition
EFI_PART=$(lsblk -rpno NAME,PARTTYPE | grep c12a7328 | cut -d' ' -f1 | head -n1)

if [ -z "$EFI_PART" ]; then
  echo "[ERROR] EFI partition not found"
  exit 1
fi

echo "[SavarezOS] EFI: $EFI_PART"

# Mount ESP
mkdir -p "$ESP"
mount "$EFI_PART" "$ESP"

# Bind mounts
mount --bind /dev  "$TARGET/dev"
mount --bind /proc "$TARGET/proc"
mount --bind /sys  "$TARGET/sys"

# Install GRUB
chroot "$TARGET" grub-install \
  --target=x86_64-efi \
  --efi-directory=/boot/efi \
  --bootloader-id=SavarezOS \
  --recheck

# Generate config
chroot "$TARGET" update-grub

# Fallback
mkdir -p "$ESP/EFI/BOOT"

if [ -f "$ESP/EFI/SavarezOS/grubx64.efi" ]; then
  cp "$ESP/EFI/SavarezOS/grubx64.efi" \
     "$ESP/EFI/BOOT/BOOTX64.EFI"
fi

sync

echo "[SavarezOS] GRUB installed"
