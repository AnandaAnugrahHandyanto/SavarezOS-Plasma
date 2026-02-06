#!/bin/bash
set -e

TARGET=/target

mount --bind /dev  $TARGET/dev
mount --bind /proc $TARGET/proc
mount --bind /sys  $TARGET/sys

# Mount EFI
if ! mountpoint -q $TARGET/boot/efi; then
  EFI=$(lsblk -rpno NAME,PARTTYPE | grep c12a7328 | cut -d' ' -f1 | head -n1)
  mount "$EFI" $TARGET/boot/efi
fi

chroot $TARGET grub-install \
  --target=x86_64-efi \
  --efi-directory=/boot/efi \
  --bootloader-id=SavarezOS \
  --recheck

chroot $TARGET update-grub
