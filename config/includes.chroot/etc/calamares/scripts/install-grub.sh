#!/bin/bash
set -e

TARGET="/target"
ESP="$TARGET/boot/efi"

mkdir -p "$ESP"

EFI_PART=$(lsblk -rpno NAME,PARTTYPE | grep c12a7328 | cut -d' ' -f1 | head -n1)

[ -z "$EFI_PART" ] && exit 1

mount "$EFI_PART" "$ESP"

for d in dev proc sys; do
  mount --bind /$d "$TARGET/$d"
done

chroot "$TARGET" apt install -y grub-efi-amd64 efibootmgr

chroot "$TARGET" grub-install \
 --target=x86_64-efi \
 --efi-directory=/boot/efi \
 --bootloader-id=SavarezOS

chroot "$TARGET" update-grub

# Fallback
mkdir -p "$ESP/EFI/BOOT"

cp "$ESP/EFI/SavarezOS/grubx64.efi" \
   "$ESP/EFI/BOOT/BOOTX64.EFI"

sync
