#!/bin/bash

# Remove installer after install
if [ -f /etc/savarez-installed ]; then
    rm -f "$HOME/Desktop/Install-SavarezOS.desktop" 2>/dev/null
fi
