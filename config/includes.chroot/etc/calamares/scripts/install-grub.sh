#!/bin/bash
set -e

echo "[SavarezOS] Installing GRUB in target system (post-install)"

# Detect EFI or BIOS
if [ -d /sys/firmware/efi ]; then
    echo "[SavarezOS] UEFI mode detected"

    apt-get update

    apt-get install -y \
      grub-efi-amd64 \
      efibootmgr \
      os-prober

    grub-install \
      --target=x86_64-efi \
      --efi-directory=/boot/efi \
      --bootloader-id=SavarezOS \
      --recheck

else
    echo "[SavarezOS] BIOS mode detected"

    apt-get update

    apt-get install -y \
      grub-pc \
      os-prober

    grub-install /dev/sda --recheck
fi

update-grub

exit 0
