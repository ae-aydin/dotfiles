#!/bin/bash
# Claude Code status line, one row in Claude's coral with Flexoki greys:
#   ✻ model effort · ctx · 5h limit ↻reset · weekly ↻day · cache · folder ⎇ branch* · py · duration · cost at API prices
# Reads the session JSON Claude Code passes on stdin.
in=$(cat)
field() { jq -r "$1 // empty" <<<"$in"; }

model=$(field '.model.display_name')
effort=$(field '.effort.level')
dir=$(field '.workspace.current_dir')
ctx=$(field '.context_window.used_percentage')
session=$(field '.rate_limits.five_hour.used_percentage')
session_reset=$(field '.rate_limits.five_hour.resets_at')
week=$(field '.rate_limits.seven_day.used_percentage')
week_reset=$(field '.rate_limits.seven_day.resets_at')
# false would be dropped by field()'s // empty, so read this one as a plain string
cache_warm=$(jq -r '.prompt_cache.warm | values | tostring' <<<"$in")
cache_expires=$(field '.prompt_cache.expires_at')
duration_ms=$(field '.cost.total_duration_ms')
cost=$(field '.cost.total_cost_usd')

coral=$'\e[38;2;217;119;87m'
muted=$'\e[38;2;135;133;128m'
text=$'\e[38;2;206;205;195m'
reset=$'\e[0m'
dot="${muted} · ${reset}"

# "label 42%", coral once it passes the threshold
gauge() {
    local label=$1 value=${2%%.*} warn=$3
    [ -n "$value" ] || return
    local colour=$text
    [ "$value" -ge "$warn" ] && colour=$coral
    printf '%s%s %s%s%%%s' "$dot" "${muted}${label}" "$colour" "$value" "$reset"
}

# --- Claude ---
row1="${coral}✻ ${model:-Claude}${reset}"
[ -n "$effort" ] && row1+=" ${muted}${effort}${reset}"
row1+=$(gauge ctx "$ctx" 70)
row1+=$(gauge 5h "$session" 80)
[ -n "$session_reset" ] && row1+=" ${muted}↻$(date -d "@$session_reset" +%H:%M)${reset}"
row1+=$(gauge wk "$week" 80)
[ -n "$week_reset" ] && row1+=" ${muted}↻$(date -d "@$week_reset" +%a)${reset}"
# a warm cache makes the next message cheaper; show minutes until it goes cold
if [ "$cache_warm" = true ] && [ -n "$cache_expires" ]; then
    left=$(( (cache_expires - $(date +%s)) / 60 ))
    [ "$left" -gt 0 ] && row1+="${dot}${muted}cache ${text}${left}m${reset}" || row1+="${dot}${muted}cache cold${reset}"
elif [ -n "$cache_warm" ]; then
    row1+="${dot}${muted}cache cold${reset}"
fi

# --- the work ---
row2="${dot}${text}${dir##*/}${reset}"
branch=$(git -C "$dir" branch --show-current 2>/dev/null)
if [ -n "$branch" ]; then
    dirty=$(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null | head -1)
    row2+=" ${muted}⎇ ${branch}${reset}"
    [ -n "$dirty" ] && row2+="${coral}*${reset}"
fi
# project venv (uv creates .venv): "py 3.13"
if [ -f "$dir/.venv/pyvenv.cfg" ]; then
    py=$(awk -F' = ' '$1 ~ /^version/ { split($2, v, "."); print v[1] "." v[2]; exit }' "$dir/.venv/pyvenv.cfg")
    [ -n "$py" ] && row2+="${dot}${muted}py ${text}${py}${reset}"
fi
if [ -n "$duration_ms" ]; then
    mins=$(( ${duration_ms%%.*} / 60000 ))
    [ "$mins" -ge 60 ] && took="$((mins / 60))h$((mins % 60))m" || took="${mins}m"
    row2+="${dot}${muted}${took}${reset}"
fi
# what the session would cost on the API; a subscription doesn't bill it
[ -n "$cost" ] && row2+="${dot}${muted}api≈\$$(printf '%.2f' "$cost") (not billed)${reset}"

printf '%s%s' "$row1" "$row2"
