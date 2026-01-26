#!/bin/bash
set -e

sudo lb clean

sudo lb config \
  --distribution bookworm \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --bootappend-live "boot=live components splash quiet" \
  --iso-publisher "SavarezOS" \
  --iso-volume "SAVAREZOS_PLASMA"

sudo lb build
