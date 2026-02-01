#!/bin/bash
set -e

echo "[SavarezOS] Installing GRUB..."

TARGET="/target"

mount | grep "$TARGET/boot/efi" || mount /dev/disk/by-partlabel/ESP $TARGET/boot/efi || true

chroot $TARGET apt-get update

chroot $TARGET apt-get install -y \
  grub-efi-amd64 \
  grub-common \
  efibootmgr \
  os-prober

chroot $TARGET grub-install \
  --target=x86_64-efi \
  --efi-directory=/boot/efi \
  --bootloader-id=SavarezOS \
  --recheck

chroot $TARGET update-grub

echo "[SavarezOS] GRUB installed successfully."
