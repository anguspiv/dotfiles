#!/bin/bash
# Cross-platform network status with security indicators
# Supports macOS and Linux

CACHE_FILE="/tmp/tmux_network_$$"
CACHE_TTL=10  # Cache for 10 seconds

# Check cache
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [ $CACHE_AGE -lt $CACHE_TTL ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Source OS detection
source ~/.tmux/scripts/os_detect.sh
OS=$(detect_os)

check_connectivity() {
    # Quick connectivity check (works on both platforms)
    if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1 || ping -c 1 -w 1 8.8.8.8 >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

check_vpn() {
    # Cross-platform VPN detection
    if pgrep -f "openvpn\|nordvpn\|expressvpn\|wireguard\|vpn" >/dev/null 2>&1; then
        echo "🔒"
    elif [ -d /proc/sys/net/ipv4/conf/tun0 ] 2>/dev/null; then
        echo "🔒"
    else
        echo ""
    fi
}

get_network_macos() {
    # Get primary interface
    local primary_interface=$(route get default 2>/dev/null | awk '/interface:/ { print $2 }')
    
    if [[ "$primary_interface" == en* ]]; then
        # Check if it's WiFi (en0 typically) or Ethernet
        if [[ "$primary_interface" == "en0" ]] && system_profiler SPAirPortDataType 2>/dev/null | grep -q "Status: Connected"; then
            # WiFi connection
            local ssid=$(networksetup -getairportnetwork "$primary_interface" 2>/dev/null | cut -d: -f2 | xargs)
            local vpn_status=$(check_vpn)
            
            if [ -n "$ssid" ] && [[ "$ssid" != *"not associated"* ]]; then
                echo "󰤨 ${vpn_status}${ssid}"
            else
                echo "󰤨 WiFi-off"
            fi
        else
            # Ethernet connection
            local vpn_status=$(check_vpn)
            echo "󰈀 ${vpn_status}ethernet"
        fi
    else
        echo "󰤨 connected"
    fi
}

get_network_linux() {
    local vpn_status=$(check_vpn)
    
    # Method 1: Try NetworkManager (nmcli)
    if command -v nmcli >/dev/null 2>&1; then
        local connection=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
        if [ -n "$connection" ]; then
            echo "󰤨 ${vpn_status}${connection}"
            return
        fi
        
        # Check for wired connection
        local wired=$(nmcli -t -f DEVICE,TYPE,STATE dev | grep ethernet | grep connected | head -1)
        if [ -n "$wired" ]; then
            echo "󰈀 ${vpn_status}ethernet"
            return
        fi
    fi
    
    # Method 2: Try iwconfig for WiFi
    if command -v iwconfig >/dev/null 2>&1; then
        local wifi_info=$(iwconfig 2>/dev/null | grep ESSID | grep -v 'ESSID:off')
        if [ -n "$wifi_info" ]; then
            local ssid=$(echo "$wifi_info" | grep -o 'ESSID:"[^"]*"' | cut -d'"' -f2 | head -1)
            if [ -n "$ssid" ]; then
                echo "󰤨 ${vpn_status}${ssid}"
                return
            fi
        fi
    fi
    
    # Method 3: Check /proc/net/route for default route
    if [ -f /proc/net/route ]; then
        local default_iface=$(awk '/^00000000/ {print $1}' /proc/net/route 2>/dev/null | head -1)
        if [ -n "$default_iface" ]; then
            # Determine if it's wireless or wired
            if [ -d "/sys/class/net/$default_iface/wireless" ]; then
                echo "󰤨 ${vpn_status}WiFi"
            else
                echo "󰈀 ${vpn_status}ethernet"
            fi
            return
        fi
    fi
    
    # Fallback
    echo "󰤨 ${vpn_status}connected"
}

# Main execution
if ! check_connectivity; then
    echo "󰤭 offline" | tee "$CACHE_FILE"
    exit 0
fi

case $OS in
    macos)
        get_network_macos | tee "$CACHE_FILE"
        ;;
    linux)
        get_network_linux | tee "$CACHE_FILE"
        ;;
    *)
        echo "󰤨 connected" | tee "$CACHE_FILE"
        ;;
esac