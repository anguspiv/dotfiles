#!/bin/bash
# Fast battery status with warning indicators
# Uses pmset for speed on macOS

CACHE_FILE="/tmp/tmux_battery_$$"
CACHE_TTL=30  # Cache for 30 seconds

# Check cache
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [ $CACHE_AGE -lt $CACHE_TTL ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Get battery info efficiently
BATTERY_INFO=$(pmset -g batt 2>/dev/null)

if [[ $BATTERY_INFO == *"Battery"* ]]; then
    # Extract percentage and status
    PERCENTAGE=$(echo "$BATTERY_INFO" | grep -o '[0-9]*%' | head -1 | tr -d '%')
    STATUS=$(echo "$BATTERY_INFO" | grep -o 'charging\|discharging\|charged\|AC Power')
    
    # Choose icon based on percentage and status
    if [[ $STATUS == *"charging"* ]]; then
        ICON="⚡"
    elif [ "$PERCENTAGE" -gt 75 ]; then
        ICON="🔋"
    elif [ "$PERCENTAGE" -gt 50 ]; then
        ICON="🔋"
    elif [ "$PERCENTAGE" -gt 25 ]; then
        ICON="🪫"
    else
        ICON="🪫"  # Low battery warning
    fi
    
    # Warning colors will be handled in tmux config
    echo "$ICON${PERCENTAGE}%" | tee "$CACHE_FILE"
else
    echo "🔌 AC" | tee "$CACHE_FILE"
fi