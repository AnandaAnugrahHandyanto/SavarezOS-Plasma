#!/bin/bash
set -e

echo "[SavarezOS] Installing GRUB (UEFI)"

TARGET="/target"
ESP="$TARGET/boot/efi"

mkdir -p "$ESP"

# Find EFI partition
EFI_PART=$(lsblk -rpno NAME,PARTTYPE | grep c12a7328 | cut -d' ' -f1 | head -n1)

if [ -z "$EFI_PART" ]; then
  echo "[ERROR] EFI partition not found"
  exit 1
fi

echo "[SavarezOS] EFI partition: $EFI_PART"

mount "$EFI_PART" "$ESP" || true

mount --bind /dev  "$TARGET/dev"
mount --bind /proc "$TARGET/proc"
mount --bind /sys  "$TARGET/sys"

# Install GRUB
chroot "$TARGET" grub-install \
  --target=x86_64-efi \
  --efi-directory=/boot/efi \
  --boot-directory=/boot \
  --bootloader-id=SavarezOS \
  --recheck

# Generate config
chroot "$TARGET" update-grub


# Fallback EFI (for rEFInd / BIOS)
mkdir -p "$ESP/EFI/BOOT"

if [ -f "$ESP/EFI/SavarezOS/grubx64.efi" ]; then
  cp "$ESP/EFI/SavarezOS/grubx64.efi" \
     "$ESP/EFI/BOOT/BOOTX64.EFI"
fi


# Register UEFI entry
chroot "$TARGET" bash -c '
DISK=$(lsblk -no PKNAME $(findmnt -n -o SOURCE /boot/efi) | head -n1)
[ -n "$DISK" ] && efibootmgr -c \
  -d /dev/$DISK \
  -p 1 \
  -L "SavarezOS" \
  -l "\\EFI\\SavarezOS\\grubx64.efi"
' || true

sync

echo "[SavarezOS] GRUB installed"
