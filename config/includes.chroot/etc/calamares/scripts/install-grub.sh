#!/bin/bash
set -e

echo "[SavarezOS] Starting GRUB installation"

TARGET="/target"
ESP="$TARGET/boot/efi"

mkdir -p "$ESP"

# Ensure EFI is mounted
mountpoint -q "$ESP" || mount "$ESP" || true

# Install required packages
chroot "$TARGET" apt-get update

chroot "$TARGET" apt-get install -y \
    grub-efi-amd64 \
    grub-common \
    efibootmgr \
    os-prober

# Install GRUB
chroot "$TARGET" grub-install \
  --target=x86_64-efi \
  --efi-directory=/boot/efi \
  --bootloader-id=SavarezOS \
  --recheck \
  --no-nvram

# Generate config
chroot "$TARGET" update-grub

# Create fallback
FALLBACK="$ESP/EFI/BOOT"
SAVAREZ="$ESP/EFI/SavarezOS"

mkdir -p "$FALLBACK"

if [ -f "$SAVAREZ/grubx64.efi" ]; then
  cp "$SAVAREZ/grubx64.efi" "$FALLBACK/BOOTX64.EFI"
fi

sync

echo "[SavarezOS] GRUB installation finished"
