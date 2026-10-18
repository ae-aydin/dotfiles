#!/bin/bash
# Clipboard history picker: cliphist entries in fuzzel, images shown with a thumbnail.
thumbs="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-thumbs"
mkdir -p "$thumbs"
# thumbnails are cheap to rebuild, so just drop old ones instead of tracking deleted entries
find "$thumbs" -type f -mtime +7 -delete

choice=$(cliphist list | while IFS=$'\t' read -r id content; do
    if [[ $content =~ ^\[\[\ binary\ data\ .*\ (png|jpe?g|webp|bmp|gif)\  ]]; then
        thumb="$thumbs/$id.${BASH_REMATCH[1]}"
        [[ -s $thumb ]] || printf '%s\t\n' "$id" | cliphist decode > "$thumb"
        printf '%s\t%s\0icon\x1f%s\n' "$id" "$content" "$thumb"
    else
        printf '%s\t%s\n' "$id" "$content"
    fi
done | fuzzel --dmenu --with-nth=2 --font="Iosevka:weight=regular:size=12" \
    --width=110 --lines=20 --line-height=22 --vertical-pad=10 --inner-pad=4 --prompt="clip > ")

# closing the picker without a choice must not clear the clipboard
[[ -n $choice ]] && cliphist decode <<<"$choice" | wl-copy
