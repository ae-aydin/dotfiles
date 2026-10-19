#!/bin/sh
# Hover info for the cpu button: "cpu <percent> <temp C>", "mem <used GiB> <total GiB>", "gpu <util %> <temp C>"
# Ryzen package temperature (k10temp Tctl); the hwmon number changes between boots, so find it by name
for h in /sys/class/hwmon/hwmon*; do [ "$(cat "$h/name")" = k10temp ] && cpu_temp=$(( $(cat "$h/temp1_input") / 1000 )); done
s1=$(head -1 /proc/stat); sleep 0.4; s2=$(head -1 /proc/stat)
printf '%s\n%s\n' "$s1" "$s2" | awk '
    { total = 0; for (i = 2; i <= NF; i++) total += $i; idle = $5 + $6 }
    NR == 1 { t1 = total; i1 = idle }
    NR == 2 { printf "cpu %d %s\n", 100 * (1 - (idle - i1) / (total - t1)), temp }' temp="$cpu_temp"
awk '/^MemTotal/ { t = $2 } /^MemAvailable/ { a = $2 } END { printf "mem %.1f %.1f\n", (t - a) / 1048576, t / 1048576 }' /proc/meminfo
nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ' | awk -F, 'NF == 2 { printf "gpu %s %s\n", $1, $2 }'
