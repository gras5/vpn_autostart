# vpn_autostart

A lightweight, fail-safe connection watchdog for OpenWrt. It prevents routing deadlocks by checking inbound VPN traffic on startup before activating your policy-based routing service (like `podkop`, `zapret`, `sing-box`, etc.).

## Features

- **Zero Idle Overhead:** Runs exactly once during WAN startup, consuming 0% CPU in the background.
- **Fail-Safe Mode:** If the VPN server is blocked or offline, it safely disables the routing service, leaving your router with a standard working direct internet connection.
- **Interactive Installer:** Fully guided setup with native OpenWrt UCI configuration storage.

## Quick Install

Run this command via SSH on your OpenWrt router:

```bash
wget -qO- https://raw.githubusercontent.com/gras5/vpn_autostart/main/install.sh | sh
```

## How it works

1. Waits for the WAN interface to pick up an IP and completely stabilize.
2. Brings up your VPN tunnel (e.g., AmneziaWG, WireGuard).
3. Monitors **strictly inbound (`rx_packets`)** traffic for the configured amount of time.
4. If packets > 0, it starts your routing service. If 0, it safely tears down the broken interface and stops the service to prevent routing traffic into a black hole.
