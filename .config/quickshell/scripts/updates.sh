#!/bin/sh
# Info for the updates button: "<dnf count>|<flatpak count>|<driver>" where driver is set only when
# the flatpak NVIDIA GL runtime doesn't match the loaded host driver (GTK4 flatpaks open black then)
dnf=$(dnf check-upgrade -q 2>/dev/null | awk 'NF == 3 && $1 ~ /\./' | wc -l)
flatpak=$(flatpak remote-ls --updates --columns=application 2>/dev/null | wc -l)
driver=$(cat /sys/module/nvidia/version 2>/dev/null)
if [ -n "$driver" ] && ! flatpak list --runtime --columns=application | grep -qx "org.freedesktop.Platform.GL.nvidia-$(echo "$driver" | tr . -)"; then
    missing=$driver
fi
printf '%s|%s|%s\n' "$dnf" "$flatpak" "$missing"
