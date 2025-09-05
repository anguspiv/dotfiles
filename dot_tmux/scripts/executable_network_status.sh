#!/bin/bash
# Fast network status with security indicators
# Optimized for macOS

CACHE_FILE="/tmp/tmux_network_$$"
CACHE_TTL=10  # Cache for 10 seconds

# Check cache
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [ $CACHE_AGE -lt $CACHE_TTL ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Check connectivity first (fastest)
if ! ping -c 1 -W 1000 8.8.8.8 >/dev/null 2>&1; then
    echo "󰤭 offline" | tee "$CACHE_FILE"
    exit 0
fi

# Get primary interface and status
PRIMARY_INTERFACE=$(route get default 2>/dev/null | awk '/interface:/ { print $2 }')

if [[ "$PRIMARY_INTERFACE" == en* ]]; then
    # Check if it's WiFi or Ethernet
    if [[ "$PRIMARY_INTERFACE" == "en0" ]] && system_profiler SPAirPortDataType 2>/dev/null | grep -q "Status: Connected"; then
        # WiFi - check security
        SSID=$(networksetup -getairportnetwork "$PRIMARY_INTERFACE" 2>/dev/null | cut -d: -f2 | xargs)
        if [ -n "$SSID" ] && [[ "$SSID" != *"not associated"* ]]; then
            # Check for VPN (simple check)
            VPN_STATUS=""
            if pgrep -f "openvpn\|nordvpn\|expressvpn" >/dev/null 2>&1; then
                VPN_STATUS="🔒"
            fi
            echo "󰤨 $VPN_STATUS$SSID" | tee "$CACHE_FILE"
        else
            echo "󰤨 WiFi-off" | tee "$CACHE_FILE"
        fi
    else
        # Ethernet
        echo "󰈀 ethernet" | tee "$CACHE_FILE"
    fi
else
    echo "󰤨 connected" | tee "$CACHE_FILE"
fi