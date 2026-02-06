#!/usr/bin/env bash
# Clean battery status - Spaceship style

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    BATTERY_INFO=$(pmset -g batt 2>/dev/null)
    PERCENTAGE=$(echo "$BATTERY_INFO" | grep -o '[0-9]*%' | tr -d '%')
    CHARGING=$(echo "$BATTERY_INFO" | grep -q 'AC Power' && echo "charging" || echo "discharging")
else
    # Linux
    BATTERY_PATH="/sys/class/power_supply/BAT0"
    if [[ -f "$BATTERY_PATH/capacity" ]]; then
        PERCENTAGE=$(cat "$BATTERY_PATH/capacity")
        STATUS=$(cat "$BATTERY_PATH/status")
        [[ "$STATUS" == "Charging" ]] && CHARGING="charging" || CHARGING="discharging"
    else
        exit 0
    fi
fi

# Choose icon based on charge level and status
if [[ "$CHARGING" == "charging" ]]; then
    ICON="󰂄"
    COLOR="#a3be8c"  # Green
elif [[ $PERCENTAGE -ge 80 ]]; then
    ICON="󰁹"
    COLOR="#a3be8c"  # Green
elif [[ $PERCENTAGE -ge 60 ]]; then
    ICON="󰂀"
    COLOR="#88c0d0"  # Blue
elif [[ $PERCENTAGE -ge 40 ]]; then
    ICON="󰁾"
    COLOR="#ebcb8b"  # Yellow
elif [[ $PERCENTAGE -ge 20 ]]; then
    ICON="󰁼"
    COLOR="#d08770"  # Orange
else
    ICON="󰁺"
    COLOR="#bf616a"  # Red
fi

echo "#[fg=$COLOR]$ICON ${PERCENTAGE}% #[fg=#616e88]│ "
