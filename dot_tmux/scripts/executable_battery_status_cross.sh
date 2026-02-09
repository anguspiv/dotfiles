#!/bin/bash
# Cross-platform battery status with warning indicators
# Supports macOS and Linux

CACHE_FILE="/tmp/tmux_battery_$$"
CACHE_TTL=30  # Cache for 30 seconds

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

get_battery_macos() {
    local battery_info=$(pmset -g batt 2>/dev/null)
    
    if [[ $battery_info == *"Battery"* ]]; then
        local percentage=$(echo "$battery_info" | grep -o '[0-9]*%' | head -1 | tr -d '%')
        local status=$(echo "$battery_info" | grep -o 'charging\|discharging\|charged\|AC Power')
        
        # Choose icon based on percentage and status
        if [[ $status == *"charging"* ]]; then
            echo "⚡${percentage}%"
        elif [ "$percentage" -gt 75 ]; then
            echo "󰁹${percentage}%"
        elif [ "$percentage" -gt 50 ]; then
            echo "󰂀${percentage}%"
        elif [ "$percentage" -gt 25 ]; then
            echo "󰁼${percentage}%"
        else
            echo "󰁺${percentage}%"  # Low battery warning
        fi
    else
        echo "󰚥"
    fi
}

get_battery_linux() {
    # Try multiple battery detection methods
    local bat_path=""
    
    # Method 1: upower (most reliable)
    if command -v upower >/dev/null 2>&1; then
        local bat_info=$(upower -i $(upower -e | grep 'BAT') 2>/dev/null | grep -E "percentage|state")
        if [ -n "$bat_info" ]; then
            local percentage=$(echo "$bat_info" | grep percentage | grep -o '[0-9]*')
            local status=$(echo "$bat_info" | grep state | awk '{print $2}')
            
            if [[ $status == *"charging"* ]]; then
                echo "⚡${percentage}%"
            elif [ "$percentage" -gt 75 ]; then
                echo "󰁹${percentage}%"
            elif [ "$percentage" -gt 50 ]; then
                echo "󰂀${percentage}%"
            elif [ "$percentage" -gt 25 ]; then
                echo "󰁼${percentage}%"
            else
                echo "󰁺${percentage}%"
            fi
            return
        fi
    fi
    
    # Method 2: /sys/class/power_supply (fallback)
    for bat in /sys/class/power_supply/BAT*; do
        if [ -d "$bat" ]; then
            bat_path="$bat"
            break
        fi
    done
    
    if [ -n "$bat_path" ] && [ -f "$bat_path/capacity" ]; then
        local percentage=$(cat "$bat_path/capacity" 2>/dev/null)
        local status="unknown"
        
        if [ -f "$bat_path/status" ]; then
            status=$(cat "$bat_path/status" 2>/dev/null | tr '[:upper:]' '[:lower:]')
        fi
        
        if [[ $status == *"charging"* ]]; then
            echo "⚡${percentage}%"
        elif [ "$percentage" -gt 75 ]; then
            echo "󰁹${percentage}%"
        elif [ "$percentage" -gt 50 ]; then
            echo "󰂀${percentage}%"
        elif [ "$percentage" -gt 25 ]; then
            echo "󰁼${percentage}%"
        else
            echo "󰁺${percentage}%"
        fi
    else
        echo "󰚥"
    fi
}

# Main execution
case $OS in
    macos)
        get_battery_macos | tee "$CACHE_FILE"
        ;;
    linux)
        get_battery_linux | tee "$CACHE_FILE"
        ;;
    *)
        echo "󰚥" | tee "$CACHE_FILE"
        ;;
esac