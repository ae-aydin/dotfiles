#!/bin/bash
# Power menu (SUPER+END). Logout is `uwsm stop`, which stops the session's services in order before
# Hyprland (exiting Hyprland directly crashes portals, mako, hyprsunset). Restart/Shutdown go to systemd.
choice=$(printf '%s\0icon\x1f%s\n' \
    "Lock" system-lock-screen \
    "Logout" system-log-out \
    "Restart" system-reboot \
    "Shutdown" system-shutdown |
    fuzzel --dmenu --prompt="power > " --width=24 --lines=4)

case $choice in
    Lock)     loginctl lock-session ;;
    Logout)   uwsm stop ;;
    Restart)  systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
