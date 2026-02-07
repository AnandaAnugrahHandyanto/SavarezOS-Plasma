#!/bin/bash
set -e

TARGET=/target

mount --bind /dev  $TARGET/dev
mount --bind /proc $TARGET/proc
mount --bind /sys  $TARGET/sys

chroot $TARGET grub-install /dev/sda || true
chroot $TARGET grub-install \
  --target=x86_64-efi \
  --efi-directory=/boot/efi \
  --bootloader-id=SavarezOS \
  --recheck || true

chroot $TARGET update-grub
