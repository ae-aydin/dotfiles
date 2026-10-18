#!/bin/sh
# Hover info for the network button: "<type>|<connection>|<device>|<ipv4>|<dns>" for the main connected link
nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device | awk -F: '$3 == "connected" && ($2 == "ethernet" || $2 == "wifi") { print; exit }' |
while IFS=: read -r dev type _ conn; do
    ip=$(ip -4 -o addr show dev "$dev" | awk '{ print $4; exit }')
    # global resolver (DNS-over-TLS from /etc/systemd/resolved.conf.d) wins over the link's DHCP DNS
    dns=$(resolvectl status 2>/dev/null | awk '/^Global/ { g = 1 } g && /Current DNS Server:/ { print $4; exit }')
    printf '%s|%s|%s|%s|%s\n' "$type" "$conn" "$dev" "$ip" "$dns"
done
