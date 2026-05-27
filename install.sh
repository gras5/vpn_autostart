#!/bin/sh

echo "======================================"
echo "  Installing & Configuring vpn_autostart"
echo "======================================"

ask_param() {
    local prompt="$1"
    local default="$2"
    local input
    
    printf "%s [%s]: " "$prompt" "$default" >&2
    
    read input < /dev/tty
    echo "${input:-$default}"
}

if [ -z "$1" ]; then
    IFACE_1=$(ask_param "1. Enter WAN interface name (trigger)" "wan")
    DELAY_1=$(ask_param "2. WAN stabilization delay (seconds)" "30")
    IFACE_2=$(ask_param "3. Enter VPN interface name (tunnel)" "awg0")
    DELAY_2=$(ask_param "4. Tunnel traffic check delay (seconds)" "30")
    SERVICE=$(ask_param "5. Target routing service name" "podkop")
else
    IFACE_1=$1
    DELAY_1=$2
    IFACE_2=$3
    DELAY_2=$4
    SERVICE=${5:-podkop}
fi

echo -e "\nApplying the following settings:"
echo "-> Trigger Interface: $IFACE_1 (delay: $DELAY_1 sec)"
echo "-> Tunnel Interface:  $IFACE_2 (check: $DELAY_2 sec)"
echo "-> Managed Service:   $SERVICE"
echo "--------------------------------------"

cat << EOF > /etc/config/vpn_autostart
config vpn_autostart 'main'
	option trigger_interface '$IFACE_1'
	option trigger_delay '$DELAY_1'
	option tunnel_interface '$IFACE_2'
	option check_delay '$DELAY_2'
	option service_name '$SERVICE'
EOF

echo "Downloading hotplug script..."
wget -qO /etc/hotplug.d/iface/99-vpn-autostart "https://raw.githubusercontent.com/gras5/vpn_autostart/main/99-vpn-autostart"

if [ -f "/etc/hotplug.d/iface/99-vpn-autostart" ]; then
    chmod +x /etc/hotplug.d/iface/99-vpn-autostart
    echo "✔ Hotplug script installed and permissions set."
else
    echo "❌ Error: Failed to download hotplug script."
    exit 1
fi

if [ -f "/etc/init.d/$SERVICE" ]; then
    /etc/init.d/"$SERVICE" disable
    echo "✔ Autostart for $SERVICE via init disabled (now managed by hotplug)."
else
    echo "⚠ Warning: Service $SERVICE is not installed on this system yet."
fi

echo "✔ Installation completed successfully!"