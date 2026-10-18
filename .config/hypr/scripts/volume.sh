#!/bin/bash
# Volume keys: change the default sink and show one self-replacing mako popup with a bar.
case $1 in
    up)   wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
esac

# "Volume: 0.45 [MUTED]" -> 45, muted flag
read -r _ level muted < <(wpctl get-volume @DEFAULT_AUDIO_SINK@)
percent=$(awk -v l="$level" 'BEGIN { printf "%d", l * 100 + 0.5 }')
[[ -n $muted ]] && title="Muted" || title="Volume $percent%"

# reuse the previous popup's id so presses update it instead of stacking
id_file="${XDG_RUNTIME_DIR:-/tmp}/volume-notify-id"
id=$(cat "$id_file" 2>/dev/null)
notify-send -a volume -t 1200 -h int:value:"$percent" -p ${id:+-r "$id"} "$title" > "$id_file"
