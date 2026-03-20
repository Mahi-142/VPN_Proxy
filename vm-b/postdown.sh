WAN_IF="eth0"
SS_PORT="8388"
WG_PORT="51820"
VPN_SERVER_IP="YOUR_VM_A_IP_HERE"
WG_IF="wg0"

# Remove bypass routing
ip rule del fwmark 0x1 table 200 2>/dev/null
ip route flush table 200 2>/dev/null

# Remove mangle marks
iptables -t mangle -D OUTPUT -d $VPN_SERVER_IP -p udp --dport $WG_PORT -j MARK --set-mark 0x1
iptables -t mangle -D OUTPUT -p tcp --sport $SS_PORT -j MARK --set-mark 0x1
iptables -t mangle -D OUTPUT -p udp --sport $SS_PORT -j MARK --set-mark 0x1

# Remove NAT rule
iptables -t nat -D POSTROUTING -o $WG_IF -j MASQUERADE

# Remove forward rules
iptables -D FORWARD -i $WG_IF -j ACCEPT
iptables -D FORWARD -o $WG_IF -j ACCEPT

echo "PostDown rules removed"
