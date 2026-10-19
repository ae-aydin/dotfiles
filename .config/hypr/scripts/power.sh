#!/bin/bash
# Power menu (SUPER+END). Log out / reboot / shut down go through hyprshutdown, which asks apps to
# close first; --no-exit keeps Hyprland up until then so the follow-up command isn't cut off by uwsm.
shutdown() { hyprshutdown --no-exit -t "$1" -p "$2"; }

choice=$(printf '%s\0icon\x1f%s\n' \
    "Lock" system-lock-screen \
    "Suspend" system-suspend \
    "Log out" system-log-out \
    "Reboot" system-reboot \
    "Shut down" system-shutdown |
    fuzzel --dmenu --prompt="power > " --width=24 --lines=5)

case $choice in
    Lock)        loginctl lock-session ;;
    Suspend)     systemctl suspend ;;  # hypridle locks before sleep
    "Log out")   shutdown "Logging out..." "uwsm stop" ;;
    Reboot)      shutdown "Rebooting..." "systemctl reboot" ;;
    "Shut down") shutdown "Shutting down..." "systemctl poweroff" ;;
esac
