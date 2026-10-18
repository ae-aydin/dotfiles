local vars = require("host.vars")
-- SUPER = windows key

-- utility
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("SUPER + END", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- apps
hl.bind("SUPER + T", hl.dsp.exec_cmd(vars.terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd(vars.file_manager))
hl.bind("ALT + SPACE", hl.dsp.exec_cmd(vars.menu))

-- clipboard
hl.bind("SUPER + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/clipboard.sh"))

-- screenshots: copy to clipboard and save to ~/Pictures/Screenshots, SUPER+SHIFT+A annotates in swappy
local shot = "XDG_SCREENSHOTS_DIR=$HOME/Pictures/Screenshots GRIMBLAST_EDITOR='swappy -f' grimblast --notify "
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(shot .. "copysave area"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd(shot .. "copysave active"))
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd(shot .. "copysave output"))
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd(shot .. "edit area"))

-- focus window
hl.bind("SUPER + LEFT", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + RIGHT", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + UP", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + DOWN", hl.dsp.focus({ direction = "down" }))

-- move window
hl.bind("SUPER + SHIFT + LEFT", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + RIGHT", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + UP", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + DOWN", hl.dsp.window.move({ direction = "down" }))

-- switch workspace (1-5 main monitor, 6-8 secondary, see host/workspaces.lua)
for i = 1, 8 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- special workspace (scratchpad)
hl.bind("SUPER + N",  hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + N", hl.dsp.window.move({ workspace = "special:magic" }))

-- scroll through existing workspaces
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- move/resize window using LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- media keys (locked = also work on the lock screen)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh mute"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- same controls on SUPER+ALT for keyboards without media keys (Apex 3 TKL)
hl.bind("SUPER + ALT + UP",    hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh up"),   { locked = true, repeating = true })
hl.bind("SUPER + ALT + DOWN",  hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh down"), { locked = true, repeating = true })
hl.bind("SUPER + ALT + M",     hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh mute"), { locked = true })
hl.bind("SUPER + ALT + SPACE", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("SUPER + ALT + RIGHT", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("SUPER + ALT + LEFT",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
