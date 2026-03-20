# VPN + Proxy Chain Setup 🔒

A personal project where I set up a two-hop privacy network using WireGuard and Shadowsocks on two Linux virtual machines. Built this to learn how VPNs and proxies actually work under the hood.

## How It Works

Instead of your traffic going directly to the internet, it takes this path:

[You → Shadowsocks (VM-B) → WireGuard Tunnel → VPN Server (VM-A) → Internet]


VM-B acts as a proxy that disguises your traffic, and VM-A acts as the VPN exit point. The two machines talk to each other through an encrypted WireGuard tunnel.

## What I Used

- **WireGuard** — fast, modern VPN protocol for the tunnel between the two VMs
- **Shadowsocks** — proxy protocol that makes traffic harder to detect and block
- **iptables** — to control exactly which traffic goes through the tunnel and which doesn't
- **Kali Linux** — running on both VMs inside VirtualBox

## What I Learned

- How VPNs and proxies actually work at a technical level
- Linux networking, routing tables, and iptables rules
- SSH into remote servers and managing them from terminal
- Debugging network issues (a lot of this honestly)
- How traffic flows through multiple hops

## Setup

### VM-A — WireGuard VPN Server
```bash
sudo apt install wireguard -y
wg genkey | tee private.key | wg pubkey > public.key
# Copy vm-a/wg0.conf to /etc/wireguard/wg0.conf
# Replace YOUR_PRIVATE_KEY_HERE with your actual key
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo systemctl enable --now wg-quick@wg0
```

### VM-B — Shadowsocks Proxy + WireGuard Client
```bash
sudo apt install wireguard shadowsocks-libev -y
wg genkey | tee private.key | wg pubkey > public.key
# Copy vm-b configs to their respective locations
# Replace all placeholder values with your actual keys and IPs
sudo chmod +x /etc/wireguard/postup.sh /etc/wireguard/postdown.sh
sudo systemctl enable --now shadowsocks-libev wg-quick@wg0
```

> **Note:** Replace all `YOUR_*_HERE` placeholders in the config files with your own generated keys and IP addresses before running.

## Project Structure

├── vm-a/
│   └── wg0.conf              # WireGuard server config
└── vm-b/
    ├── wg0.conf              # WireGuard client config
    ├── postup.sh             # iptables rules on tunnel start
    ├── postdown.sh           # iptables cleanup on tunnel stop
    └── shadowsocks-config.json

## Notes

- Built and tested locally on VirtualBox
- Can be deployed on real cloud servers (Oracle Cloud has a free tier that works great for this)
- All sensitive values like private keys and passwords have been replaced with placeholders
