#!/bin/bash
set -e

echo "[SavarezOS] Starting GRUB installation"

TARGET="/target"
ESP="$TARGET/boot/efi"

# Ensure EFI is mounted
echo "[SavarezOS] Checking EFI mount..."

mkdir -p "$ESP"

if ! mountpoint -q "$ESP"; then
    echo "[SavarezOS] Mounting EFI partition..."

    EFI_PART=$(lsblk -o NAME,PARTLABEL | grep -i "EFI" | awk '{print $1}' | head -n1)

    if [ -n "$EFI_PART" ]; then
        mount "/dev/$EFI_PART" "$ESP"
    else
        echo "[WARNING] EFI partition not found automatically."
    fi
fi

# Install required packages
echo "[SavarezOS] Installing GRUB packages..."

chroot "$TARGET" apt-get update

chroot "$TARGET" apt-get install -y \
    grub-efi-amd64 \
    grub-common \
    efibootmgr \
    os-prober

# Install GRUB
echo "[SavarezOS] Installing GRUB UEFI..."

chroot "$TARGET" grub-install \
    --target=x86_64-efi \
    --efi-directory=/boot/efi \
    --bootloader-id=SavarezOS \
    --recheck

# Generate config
echo "[SavarezOS] Generating GRUB config..."

chroot "$TARGET" update-grub

# Create fallback bootloader
echo "[SavarezOS] Creating fallback EFI..."

FALLBACK="$ESP/EFI/BOOT"
SAVAREZ="$ESP/EFI/SavarezOS"

mkdir -p "$FALLBACK"

if [ -f "$SAVAREZ/grubx64.efi" ]; then
    cp "$SAVAREZ/grubx64.efi" "$FALLBACK/BOOTX64.EFI"
    echo "[SavarezOS] Fallback BOOTX64.EFI created"
else
    echo "[WARNING] grubx64.efi not found, fallback skipped"
fi

# Sync disk
sync

echo "[SavarezOS] GRUB installation finished"

exit 0
