#!/bin/bash
# Keybind cheat sheet: live binds that have a desc (theme/keybinds.lua), shown in fuzzel.
# Binds sharing a desc and modifiers are merged onto one line (arrows, workspace numbers).
# IosevkaTerm keeps arrows one cell wide (plain Iosevka draws them double), so the columns line up.
hyprctl binds -j | jq -r '
    def mods: [
        (if (.modmask / 64 | floor) % 2 == 1 then "SUPER" else empty end),
        (if (.modmask / 4  | floor) % 2 == 1 then "CTRL"  else empty end),
        (if (.modmask / 8  | floor) % 2 == 1 then "ALT"   else empty end),
        (if (.modmask      | floor) % 2 == 1 then "SHIFT" else empty end)
    ] | join(" + ");
    def key: {"mouse:272": "LMB", "mouse:273": "RMB", "mouse_down": "scroll", "mouse_up": "scroll",
              "LEFT": "←", "RIGHT": "→", "UP": "↑", "DOWN": "↓"}[.key] // .key;
    def keylist: unique as $k
        | if ($k | length) > 1 and ($k | all(test("^[0-9]$"))) then "\($k[0])-\($k[-1])" else $k | join(" ") end;

    [.[] | select(.has_description) | {m: mods, k: key, d: .description}]
    | reduce .[] as $b ({order: [], g: {}};
        ($b.m + "|" + $b.d) as $id
        | if .g[$id] then .g[$id].k += [$b.k]
          else .order += [$id] | .g[$id] = {m: $b.m, d: $b.d, k: [$b.k]} end)
    | .order[] as $id | .g[$id]
    | "\(.m) + \(.k | keylist)\t\(.d)"
' | column -t -s $'\t' | fuzzel --dmenu --prompt="keys > " --width=60 --lines=20 \
    --font="IosevkaTerm Nerd Font Mono:weight=regular:size=16" >/dev/null
