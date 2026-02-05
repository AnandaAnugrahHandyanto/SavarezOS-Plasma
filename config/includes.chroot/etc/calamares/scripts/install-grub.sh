#!/bin/bash
set -e

TARGET=/target
ESP=/boot/efi

mount --bind /dev  $TARGET/dev
mount --bind /proc $TARGET/proc
mount --bind /sys  $TARGET/sys

# Mount ESP
chroot $TARGET mkdir -p $ESP
chroot $TARGET mount $(lsblk -rpno NAME,PARTTYPE | grep c12a7328 | cut -d' ' -f1 | head -n1) $ESP || true

# Install grub
chroot $TARGET grub-install \
  --target=x86_64-efi \
  --efi-directory=$ESP \
  --bootloader-id=SavarezOS \
  --recheck

# Fallback
chroot $TARGET mkdir -p $ESP/EFI/BOOT
chroot $TARGET cp $ESP/EFI/SavarezOS/grubx64.efi \
  $ESP/EFI/BOOT/BOOTX64.EFI || true

chroot $TARGET update-grub
