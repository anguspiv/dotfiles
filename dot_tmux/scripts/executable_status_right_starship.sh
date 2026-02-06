#!/usr/bin/env bash
# Starship-style right status with Nerd Font icons on RIGHT

OUTPUT=""

# Chezmoi (text → icon on right)
if command -v chezmoi >/dev/null 2>&1; then
    LOCAL_CHANGES=$(chezmoi status 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$LOCAL_CHANGES" -gt 0 ]]; then
        OUTPUT+="#[fg=#ebcb8b]${LOCAL_CHANGES}   "
    else
        OUTPUT+="#[fg=#a3be8c]  "
    fi
fi

# Battery (percentage → icon on right)
if [[ "$OSTYPE" == "darwin"* ]]; then
    BATTERY_INFO=$(pmset -g batt 2>/dev/null)
    PERCENTAGE=$(echo "$BATTERY_INFO" | grep -o '[0-9]*%' | tr -d '%')
    CHARGING=$(echo "$BATTERY_INFO" | grep -q 'AC Power' && echo "1" || echo "0")

    if [[ $CHARGING -eq 1 ]]; then
        OUTPUT+="#[fg=#a3be8c]${PERCENTAGE}%   "
    elif [[ $PERCENTAGE -ge 80 ]]; then
        OUTPUT+="#[fg=#a3be8c]${PERCENTAGE}%   "
    elif [[ $PERCENTAGE -ge 60 ]]; then
        OUTPUT+="#[fg=#88c0d0]${PERCENTAGE}%   "
    elif [[ $PERCENTAGE -ge 40 ]]; then
        OUTPUT+="#[fg=#ebcb8b]${PERCENTAGE}%   "
    else
        OUTPUT+="#[fg=#bf616a]${PERCENTAGE}%   "
    fi
fi

# CPU (percentage → icon on right)
if [[ "$OSTYPE" == "darwin"* ]]; then
    CPU=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')
else
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)
fi

if [[ $CPU -ge 80 ]]; then
    OUTPUT+="#[fg=#bf616a]${CPU}%   "
elif [[ $CPU -ge 50 ]]; then
    OUTPUT+="#[fg=#ebcb8b]${CPU}%   "
else
    OUTPUT+="#[fg=#a3be8c]${CPU}%   "
fi

# Memory (percentage → icon on right)
if [[ "$OSTYPE" == "darwin"* ]]; then
    MEM=$(ps -A -o %mem | awk '{s+=$1} END {printf "%.0f", s}')
else
    MEM=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
fi

if [[ $MEM -ge 80 ]]; then
    OUTPUT+="#[fg=#bf616a]${MEM}%   "
elif [[ $MEM -ge 60 ]]; then
    OUTPUT+="#[fg=#ebcb8b]${MEM}%   "
else
    OUTPUT+="#[fg=#a3be8c]${MEM}%   "
fi

# Time (time → icon on right)
OUTPUT+="#[fg=#88c0d0]$(date +'%H:%M')   "

# Date (date → icon on right with right padding)
OUTPUT+="#[fg=#81a1c1]$(date +'%b %d')    "

echo "$OUTPUT"
