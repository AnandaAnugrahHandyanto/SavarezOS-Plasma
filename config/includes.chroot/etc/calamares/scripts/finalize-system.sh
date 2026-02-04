#!/bin/bash
set -e

echo "[SavarezOS] Finalizing system"

# Remove installer
rm -f /usr/share/applications/install-savarezos.desktop || true
rm -f /home/*/Desktop/Install-SavarezOS.desktop || true

# SDDM
mkdir -p /etc/sddm.conf.d

cat > /etc/sddm.conf.d/10-savarez.conf <<EOF
[Theme]
Current=savarez
EOF

# Update grub
update-grub || true

sync

echo "[SavarezOS] Finalization done"
