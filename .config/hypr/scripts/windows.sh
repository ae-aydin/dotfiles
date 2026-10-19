#!/bin/bash
# Window switcher (SUPER+TAB): open windows in fuzzel as "<workspace>  <app> · <title>", most recently
# focused first with the previous window preselected (Enter = jump back). Name and icon come from the
# app's desktop entry, matched by file name or StartupWMClass.
dirs=(~/.local/share/applications /var/lib/flatpak/exports/share/applications /usr/share/applications)

# window class -> "<Name>\t<Icon>" from its desktop entry; falls back to the class itself
entry_for() {
    local f d
    f=$(find "${dirs[@]}" -maxdepth 1 -iname "$1.desktop" 2>/dev/null | head -1)
    if [[ -z $f ]]; then
        for d in "${dirs[@]}"; do
            f=$(grep -lisx "StartupWMClass=$1" "$d"/*.desktop 2>/dev/null | head -1)
            [[ -n $f ]] && break
        done
    fi
    if [[ -n $f ]]; then
        printf '%s\t%s\n' "$(sed -n 's/^Name=//p' "$f" | head -1)" "$(sed -n 's/^Icon=//p' "$f" | head -1)"
    else
        printf '%s\t%s\n' "${1##*.}" "${1,,}"
    fi
}

# one line per window: "<ws>  <name> · <title>" TAB address, plus fuzzel's icon field (NUL-separated,
# so it's printed straight to the pipe; bash variables can't hold NUL)
list() {
    declare -A seen
    local sep suffix
    while IFS=$'\t' read -r ws class title addr; do
        [[ -n ${seen[$class]+x} ]] || seen[$class]=$(entry_for "$class")
        IFS=$'\t' read -r name icon <<<"${seen[$class]}"
        # drop a trailing " — Mozilla Firefox" / " - Dolphin" style suffix that repeats the app name
        for sep in " — " " - "; do
            suffix=${title##*"$sep"}
            [[ $title == *"$sep"* && ${suffix,,} == *"${name,,}"* ]] && title=${title%"$sep"*}
        done
        printf '%s  %s · %s\t%s\0icon\x1f%s\n' "$ws" "$name" "$title" "$addr" "$icon"
    done < <(hyprctl clients -j | jq -r '
        sort_by(.focusHistoryID)[] | select(.mapped)
        | [(.workspace.name | sub("^special:.*"; "S")), .class, .title, .address] | @tsv')
}

count=$(hyprctl clients -j | jq '[.[] | select(.mapped)] | length')
(( count )) || exit 0
addr=$(list | fuzzel --dmenu --prompt="window > " --with-nth=1 --accept-nth=2 --width=70 \
    --select-index=$(( count > 1 ? 1 : 0 )))
[[ -n $addr ]] && hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })" >/dev/null
