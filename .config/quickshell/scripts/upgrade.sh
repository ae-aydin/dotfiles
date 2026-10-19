#!/bin/bash
# Run from the updates button in its own ghostty: system packages, then flatpaks
# (flatpak update also pulls the NVIDIA GL runtime matching the loaded driver)
sudo dnf upgrade --refresh
echo
flatpak update
echo
read -n 1 -s -r -p "Done. Press any key to close."
