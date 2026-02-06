#!/usr/bin/env bash
# Clean network status - Spaceship style

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    WIFI_STATUS=$(networksetup -getairportnetwork en0 2>/dev/null | grep -v "not associated")
    if [[ -n "$WIFI_STATUS" ]]; then
        SSID=$(echo "$WIFI_STATUS" | awk -F': ' '{print $2}')
        echo "#[fg=#88c0d0]󰤨 ${SSID} #[fg=#616e88]│ "
    else
        # Check ethernet
        ETH_STATUS=$(ifconfig en1 2>/dev/null | grep "status: active")
        if [[ -n "$ETH_STATUS" ]]; then
            echo "#[fg=#88c0d0]󰈀 #[fg=#616e88]│ "
        else
            echo "#[fg=#bf616a]󰤭 #[fg=#616e88]│ "
        fi
    fi
else
    # Linux
    if command -v nmcli >/dev/null 2>&1; then
        WIFI=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
        if [[ -n "$WIFI" ]]; then
            echo "#[fg=#88c0d0]󰤨 ${WIFI} #[fg=#616e88]│ "
        else
            echo "#[fg=#bf616a]󰤭 #[fg=#616e88]│ "
        fi
    else
        exit 0
    fi
fi
