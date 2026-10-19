local vars = require("host.vars")
-- SUPER = windows key
-- desc = shown in the SUPER+K cheat sheet (scripts/keybinds.sh); binds without one are left out

-- utility
hl.bind("SUPER + Q", hl.dsp.window.close(), { desc = "Close window" })
hl.bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }), { desc = "Toggle floating" })
hl.bind("SUPER + P", hl.dsp.window.pseudo(), { desc = "Toggle pseudo-tiling" })
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"), { desc = "Toggle split direction" })
hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"), { desc = "Lock screen" })
hl.bind("SUPER + END", hl.dsp.exec_cmd("~/.config/hypr/scripts/power.sh"), { desc = "Power menu" })
hl.bind("SUPER + K", hl.dsp.exec_cmd("~/.config/hypr/scripts/keybinds.sh"), { desc = "Show keybinds" })

-- apps
hl.bind("SUPER + T", hl.dsp.exec_cmd(vars.terminal), { desc = "Terminal" })
hl.bind("SUPER + E", hl.dsp.exec_cmd(vars.file_manager), { desc = "File manager" })
hl.bind("ALT + SPACE", hl.dsp.exec_cmd(vars.menu), { desc = "App launcher" })

-- clipboard
hl.bind("SUPER + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/clipboard.sh"), { desc = "Clipboard history" })

-- calculator
hl.bind("SUPER + C", hl.dsp.exec_cmd("~/.config/hypr/scripts/calc.sh"), { desc = "Calculator" })

-- screenshots: copy to clipboard and save to ~/Pictures/Screenshots, SUPER+SHIFT+A annotates in swappy
local shot = "XDG_SCREENSHOTS_DIR=$HOME/Pictures/Screenshots GRIMBLAST_EDITOR='swappy -f' grimblast --notify "
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(shot .. "copysave area"), { desc = "Screenshot area" })
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd(shot .. "copysave active"), { desc = "Screenshot window" })
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd(shot .. "copysave output"), { desc = "Screenshot monitor" })
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd(shot .. "edit area"), { desc = "Screenshot area and annotate" })

-- focus window
hl.bind("SUPER + LEFT", hl.dsp.focus({ direction = "left" }), { desc = "Focus window" })
hl.bind("SUPER + RIGHT", hl.dsp.focus({ direction = "right" }), { desc = "Focus window" })
hl.bind("SUPER + UP", hl.dsp.focus({ direction = "up" }), { desc = "Focus window" })
hl.bind("SUPER + DOWN", hl.dsp.focus({ direction = "down" }), { desc = "Focus window" })
hl.bind("SUPER + TAB", hl.dsp.exec_cmd("~/.config/hypr/scripts/windows.sh"), { desc = "Switch window" })

-- move window
hl.bind("SUPER + SHIFT + LEFT", hl.dsp.window.move({ direction = "left" }), { desc = "Move window" })
hl.bind("SUPER + SHIFT + RIGHT", hl.dsp.window.move({ direction = "right" }), { desc = "Move window" })
hl.bind("SUPER + SHIFT + UP", hl.dsp.window.move({ direction = "up" }), { desc = "Move window" })
hl.bind("SUPER + SHIFT + DOWN", hl.dsp.window.move({ direction = "down" }), { desc = "Move window" })

-- switch workspace (1-5 main monitor, 6-8 secondary, see host/workspaces.lua)
for i = 1, 8 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }), { desc = "Go to workspace" })
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }), { desc = "Move window to workspace" })
end

-- special workspace (scratchpad)
hl.bind("SUPER + N",  hl.dsp.workspace.toggle_special("magic"), { desc = "Toggle scratchpad" })
hl.bind("SUPER + SHIFT + N", hl.dsp.window.move({ workspace = "special:magic" }), { desc = "Move window to scratchpad" })

-- scroll through existing workspaces
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { desc = "Next / previous workspace" })
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { desc = "Next / previous workspace" })

-- move/resize window using LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, desc = "Drag window" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, desc = "Resize window" })

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
hl.bind("SUPER + ALT + UP",    hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh up"),   { locked = true, repeating = true, desc = "Volume up / down" })
hl.bind("SUPER + ALT + DOWN",  hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh down"), { locked = true, repeating = true, desc = "Volume up / down" })
hl.bind("SUPER + ALT + M",     hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh mute"), { locked = true, desc = "Mute" })
hl.bind("SUPER + ALT + SPACE", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, desc = "Play / pause" })
hl.bind("SUPER + ALT + RIGHT", hl.dsp.exec_cmd("playerctl next"),       { locked = true, desc = "Next / previous track" })
hl.bind("SUPER + ALT + LEFT",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true, desc = "Next / previous track" })
