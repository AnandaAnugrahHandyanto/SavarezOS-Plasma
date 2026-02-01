#!/bin/bash
set -e

echo "[SavarezOS] Installing GRUB (UEFI Safe Mode)"

TARGET="/target"
ESP="$TARGET/boot/efi"

mkdir -p "$ESP"

# Find EFI partition (GPT type)
EFI_PART=$(lsblk -rpno NAME,PARTTYPE | grep c12a7328 | cut -d' ' -f1 | head -n1)

if [ -z "$EFI_PART" ]; then
  echo "[ERROR] EFI partition not found"
  exit 1
fi

echo "[SavarezOS] EFI partition: $EFI_PART"

mount "$EFI_PART" "$ESP"

# Install packages
chroot "$TARGET" apt-get update

chroot "$TARGET" apt-get install -y \
  grub-efi-amd64 \
  grub-common \
  shim-signed \
  efibootmgr \
  os-prober

# Install GRUB (REGISTER to UEFI!)
chroot "$TARGET" grub-install \
  --target=x86_64-efi \
  --efi-directory=/boot/efi \
  --bootloader-id=SavarezOS \
  --recheck

# Generate config
chroot "$TARGET" update-grub

# Create fallback (VBox safe)
FALLBACK="$ESP/EFI/BOOT"
SAVAREZ="$ESP/EFI/SavarezOS"

mkdir -p "$FALLBACK"

if [ -f "$SAVAREZ/grubx64.efi" ]; then
  cp "$SAVAREZ/grubx64.efi" "$FALLBACK/BOOTX64.EFI"
fi

# Force boot order
chroot "$TARGET" bash -c '
ID=$(efibootmgr | grep SavarezOS | head -n1 | sed "s/Boot//;s/*//")
[ -n "$ID" ] && efibootmgr -o $ID
'

sync

echo "[SavarezOS] GRUB UEFI installed successfully"
