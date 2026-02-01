#!/bin/bash
set -e

echo "[SavarezOS] Fixing GRUB manually"

# Bind mount essentials
mount --bind /dev /target/dev
mount --bind /proc /target/proc
mount --bind /sys /target/sys

# Copy grub tools if missing
if [ ! -f /target/usr/sbin/grub-install ]; then
  echo "Copying grub from live system..."
  cp -a /usr/sbin/grub-install /target/usr/sbin/
  cp -a /usr/lib/grub /target/usr/lib/
  cp -a /usr/share/grub /target/usr/share/
fi

# Chroot and install
chroot /target grub-install \
  --target=x86_64-efi \
  --efi-directory=/boot/efi \
  --bootloader-id=SavarezOS \
  --recheck

chroot /target update-grub

umount /target/dev
umount /target/proc
umount /target/sys

exit 0
