WAN_IF="eth0"
SS_PORT="8388"
WG_PORT="51820"
VPN_SERVER_IP="YOUR_VM-A_IP_ADDRESS"
WG_IF="wg0"

# Create bypass routing table
ip rule add fwmark 0x1 table 200 priority 100
ip route add default via 10.0.2.2 dev $WAN_IF table 200

# Mark WireGuard tunnel traffic to bypass wg0
iptables -t mangle -A OUTPUT -d $VPN_SERVER_IP -p udp --dport $WG_PORT -j MARK --set-mark 0x1

# Mark Shadowsocks traffic to bypass wg0
iptables -t mangle -A OUTPUT -p tcp --sport $SS_PORT -j MARK --set-mark 0x1
iptables -t mangle -A OUTPUT -p udp --sport $SS_PORT -j MARK --set-mark 0x1

# NAT traffic going through wg0
iptables -t nat -A POSTROUTING -o $WG_IF -j MASQUERADE

# Allow forwarding
iptables -A FORWARD -i $WG_IF -j ACCEPT
iptables -A FORWARD -o $WG_IF -j ACCEPT

echo "PostUp rules applied"
