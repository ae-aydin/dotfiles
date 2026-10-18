hl.on("hyprland.start", function ()
  -- uwsm only exports the basics; this hands host/env.lua's vars (Qt theme etc.) to D-Bus/systemd-started apps
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  -- admin password prompts for GUI apps (pkexec): KDE's agent, tied to the uwsm session
  hl.exec_cmd("systemctl --user start plasma-polkit-agent.service")
  hl.exec_cmd("/usr/libexec/pam_kwallet_init & qs & mako & hyprpaper & hypridle")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  -- start on the main monitor's first workspace instead of whichever output came up first
  hl.dispatch(hl.dsp.focus({ workspace = 1 }))
end)
