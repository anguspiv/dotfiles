#!/usr/bin/env bash
# Starship-style battery status

if [[ "$OSTYPE" == "darwin"* ]]; then
    BATTERY_INFO=$(pmset -g batt 2>/dev/null)
    PERCENTAGE=$(echo "$BATTERY_INFO" | grep -o '[0-9]*%' | tr -d '%')
    CHARGING=$(echo "$BATTERY_INFO" | grep -q 'AC Power' && echo "charging" || echo "discharging")
else
    BATTERY_PATH="/sys/class/power_supply/BAT0"
    if [[ -f "$BATTERY_PATH/capacity" ]]; then
        PERCENTAGE=$(cat "$BATTERY_PATH/capacity")
        STATUS=$(cat "$BATTERY_PATH/status")
        [[ "$STATUS" == "Charging" ]] && CHARGING="charging" || CHARGING="discharging"
    else
        exit 0
    fi
fi

if [[ "$CHARGING" == "charging" ]]; then
    ICON="󰂄"
    COLOR="#a3be8c"
elif [[ $PERCENTAGE -ge 80 ]]; then
    ICON="󰁹"
    COLOR="#a3be8c"
elif [[ $PERCENTAGE -ge 60 ]]; then
    ICON="󰂀"
    COLOR="#88c0d0"
elif [[ $PERCENTAGE -ge 40 ]]; then
    ICON="󰁾"
    COLOR="#ebcb8b"
elif [[ $PERCENTAGE -ge 20 ]]; then
    ICON="󰁼"
    COLOR="#d08770"
else
    ICON="󰁺"
    COLOR="#bf616a"
fi

echo "#[fg=$COLOR]$ICON ${PERCENTAGE}% "
