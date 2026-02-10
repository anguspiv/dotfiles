#!/usr/bin/env bash
# Starship-style right status - icons on RIGHT of values

OUTPUT=""

# Filled powerline arrow (U+E0B2) and thin arrow (U+E0B3)
FILLED_ARROW=$(printf '\xee\x82\xb2')
THIN_ARROW=$(printf '\xee\x82\xb3')

# Start with padding
OUTPUT+="   "

# Determine network status and color first
NETWORK_OUTPUT=""
NETWORK_COLOR="#a3be8c"  # default green
NETWORK_BG=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ping -c 1 -W 1000 8.8.8.8 >/dev/null 2>&1; then
        PRIMARY_INTERFACE=$(route get default 2>/dev/null | awk '/interface:/ { print $2 }')
        if [[ "$PRIMARY_INTERFACE" == en* ]]; then
            # Check if en0 has WiFi capability and is connected
            if [[ "$PRIMARY_INTERFACE" == "en0" ]]; then
                # Try system_profiler first (more reliable)
                SSID=$(system_profiler SPAirPortDataType 2>/dev/null | grep -A 1 "Current Network Information:" | tail -n +2 | head -1 | cut -d: -f1 | xargs)
                
                # Fallback to networksetup if system_profiler fails
                if [ -z "$SSID" ] || [[ "$SSID" == *"Network Type"* ]]; then
                    SSID=$(networksetup -getairportnetwork "$PRIMARY_INTERFACE" 2>/dev/null | cut -d: -f2 | xargs)
                fi
                
                if [ -n "$SSID" ] && [[ "$SSID" != *"not associated"* ]] && [[ "$SSID" != *"Network Type"* ]]; then
                    # Handle redacted SSID
                    if [[ "$SSID" == "<redacted>" ]]; then
                        NETWORK_OUTPUT="WiFi 󰤨"
                    else
                        NETWORK_OUTPUT="${SSID} 󰤨"
                    fi
                    NETWORK_COLOR="#a3be8c"
                else
                    # Check if en0 has IP (could be ethernet/USB-C adapter on en0)
                    if ifconfig "$PRIMARY_INTERFACE" | grep -q "inet [0-9]"; then
                        NETWORK_OUTPUT="Wired 󰈀"
                        NETWORK_COLOR="#a3be8c"
                    else
                        NETWORK_OUTPUT="Down 󰤭"
                        NETWORK_COLOR="#bf616a"
                        NETWORK_BG="yes"
                    fi
                fi
            else
                NETWORK_OUTPUT="Eth 󰈀"
                NETWORK_COLOR="#a3be8c"
            fi
        else
            NETWORK_OUTPUT="Up 󰤨"
            NETWORK_COLOR="#a3be8c"
        fi
    else
        NETWORK_OUTPUT="Down 󰤭"
        NETWORK_COLOR="#bf616a"
        NETWORK_BG="yes"
    fi
fi

# Arrow before network
if [[ -n "$NETWORK_BG" ]]; then
    OUTPUT+="#[fg=${NETWORK_COLOR},bg=#2e3440]${FILLED_ARROW}#[bg=${NETWORK_COLOR},fg=#2e3440,bold] ${NETWORK_OUTPUT} "
else
    OUTPUT+="#[fg=${NETWORK_COLOR}]${THIN_ARROW} #[fg=${NETWORK_COLOR}]${NETWORK_OUTPUT}"
fi

# Determine chezmoi status and color
CHEZMOI_BG=""
if command -v chezmoi >/dev/null 2>&1; then
    LOCAL_CHANGES=$(chezmoi status 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$LOCAL_CHANGES" -gt 0 ]]; then
        CHEZMOI_COLOR="#ebcb8b"
        CHEZMOI_OUTPUT="${LOCAL_CHANGES} 󰆓"
        CHEZMOI_BG="yes"
    else
        CHEZMOI_COLOR="#a3be8c"
        CHEZMOI_OUTPUT="Synced 󰄬"
    fi
    
    # Arrow before chezmoi - check if previous section had background
    if [[ -n "$CHEZMOI_BG" ]]; then
        if [[ -n "$NETWORK_BG" ]]; then
            OUTPUT+="#[fg=${CHEZMOI_COLOR},bg=${NETWORK_COLOR}]${FILLED_ARROW}#[bg=${CHEZMOI_COLOR},fg=#2e3440,bold] ${CHEZMOI_OUTPUT} "
        else
            OUTPUT+=" #[fg=${CHEZMOI_COLOR},bg=#2e3440]${FILLED_ARROW}#[bg=${CHEZMOI_COLOR},fg=#2e3440,bold] ${CHEZMOI_OUTPUT} "
        fi
    else
        if [[ -n "$NETWORK_BG" ]]; then
            OUTPUT+="#[fg=#2e3440,bg=${NETWORK_COLOR}]${FILLED_ARROW}#[default] ${CHEZMOI_OUTPUT}"
        else
            OUTPUT+=" #[fg=${CHEZMOI_COLOR}]${THIN_ARROW} #[fg=${CHEZMOI_COLOR}]${CHEZMOI_OUTPUT}"
        fi
    fi
fi

# Determine battery status and color
BATTERY_BG=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    BATTERY_INFO=$(pmset -g batt 2>/dev/null)
    PERCENTAGE=$(echo "$BATTERY_INFO" | grep -o '[0-9]*%' | tr -d '%')
    CHARGING=$(echo "$BATTERY_INFO" | grep -q 'AC Power' && echo "1" || echo "0")

    if [[ $CHARGING -eq 1 ]]; then
        BATTERY_COLOR="#a3be8c"
        BATTERY_OUTPUT="${PERCENTAGE}% 󱐋"
    elif [[ $PERCENTAGE -ge 80 ]]; then
        BATTERY_COLOR="#a3be8c"
        BATTERY_OUTPUT="${PERCENTAGE}% 󰁹"
    elif [[ $PERCENTAGE -ge 60 ]]; then
        BATTERY_COLOR="#88c0d0"
        BATTERY_OUTPUT="${PERCENTAGE}% 󰂀"
    elif [[ $PERCENTAGE -ge 40 ]]; then
        BATTERY_COLOR="#ebcb8b"
        BATTERY_OUTPUT="${PERCENTAGE}% 󰁾"
        BATTERY_BG="yes"
    else
        BATTERY_COLOR="#bf616a"
        BATTERY_OUTPUT="${PERCENTAGE}% 󰁺"
        BATTERY_BG="yes"
    fi
    
    # Arrow before battery - check if previous section had background
    if [[ -n "$BATTERY_BG" ]]; then
        if [[ -n "$CHEZMOI_BG" ]]; then
            OUTPUT+="#[fg=${BATTERY_COLOR},bg=${CHEZMOI_COLOR}]${FILLED_ARROW}#[bg=${BATTERY_COLOR},fg=#2e3440,bold] ${BATTERY_OUTPUT} "
        else
            OUTPUT+=" #[fg=${BATTERY_COLOR},bg=#2e3440]${FILLED_ARROW}#[bg=${BATTERY_COLOR},fg=#2e3440,bold] ${BATTERY_OUTPUT} "
        fi
    else
        if [[ -n "$CHEZMOI_BG" ]]; then
            OUTPUT+="#[fg=#2e3440,bg=${CHEZMOI_COLOR}]${FILLED_ARROW}#[default] ${BATTERY_OUTPUT}"
        else
            OUTPUT+=" #[fg=${BATTERY_COLOR}]${THIN_ARROW} #[fg=${BATTERY_COLOR}]${BATTERY_OUTPUT}"
        fi
    fi
fi

# Determine CPU status and color
CPU_BG=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    CPU=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')
else
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)
fi

if [[ $CPU -ge 80 ]]; then
    CPU_COLOR="#bf616a"
    CPU_BG="yes"
elif [[ $CPU -ge 50 ]]; then
    CPU_COLOR="#ebcb8b"
    CPU_BG="yes"
else
    CPU_COLOR="#a3be8c"
fi

# Arrow before CPU - check if previous section had background
if [[ -n "$CPU_BG" ]]; then
    if [[ -n "$BATTERY_BG" ]]; then
        OUTPUT+="#[fg=${CPU_COLOR},bg=${BATTERY_COLOR}]${FILLED_ARROW}#[bg=${CPU_COLOR},fg=#2e3440,bold] ${CPU}% 󰻠 "
    else
        OUTPUT+=" #[fg=${CPU_COLOR},bg=#2e3440]${FILLED_ARROW}#[bg=${CPU_COLOR},fg=#2e3440,bold] ${CPU}% 󰻠 "
    fi
else
    if [[ -n "$BATTERY_BG" ]]; then
        OUTPUT+="#[fg=#2e3440,bg=${BATTERY_COLOR}]${FILLED_ARROW}#[default] ${CPU}% 󰻠"
    else
        OUTPUT+=" #[fg=${CPU_COLOR}]${THIN_ARROW} #[fg=${CPU_COLOR}]${CPU}% 󰻠"
    fi
fi

# Determine memory status and color
MEM_BG=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    MEM=$(ps -A -o %mem | awk '{s+=$1} END {printf "%.0f", s}')
else
    MEM=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
fi

if [[ $MEM -ge 80 ]]; then
    MEM_COLOR="#bf616a"
    MEM_BG="yes"
elif [[ $MEM -ge 60 ]]; then
    MEM_COLOR="#ebcb8b"
    MEM_BG="yes"
else
    MEM_COLOR="#a3be8c"
fi

# Arrow before memory - check if previous section had background
if [[ -n "$MEM_BG" ]]; then
    if [[ -n "$CPU_BG" ]]; then
        OUTPUT+="#[fg=${MEM_COLOR},bg=${CPU_COLOR}]${FILLED_ARROW}#[bg=${MEM_COLOR},fg=#2e3440,bold] ${MEM}% 󰍛 "
    else
        OUTPUT+=" #[fg=${MEM_COLOR},bg=#2e3440]${FILLED_ARROW}#[bg=${MEM_COLOR},fg=#2e3440,bold] ${MEM}% 󰍛 "
    fi
else
    if [[ -n "$CPU_BG" ]]; then
        OUTPUT+="#[fg=#2e3440,bg=${CPU_COLOR}]${FILLED_ARROW}#[default] ${MEM}% 󰍛"
    else
        OUTPUT+=" #[fg=${MEM_COLOR}]${THIN_ARROW} #[fg=${MEM_COLOR}]${MEM}% 󰍛"
    fi
fi

# Time (fixed color)
TIME_COLOR="#88c0d0"
if [[ -n "$MEM_BG" ]]; then
    OUTPUT+="#[fg=#2e3440,bg=${MEM_COLOR}]${FILLED_ARROW}#[default] $(date +'%H:%M') 󰥔"
else
    OUTPUT+=" #[fg=${TIME_COLOR}]${THIN_ARROW} #[fg=${TIME_COLOR}]$(date +'%H:%M') 󰥔"
fi

# Date (fixed color)
DATE_COLOR="#81a1c1"
OUTPUT+=" #[fg=${DATE_COLOR}]${THIN_ARROW} #[fg=${DATE_COLOR}]$(date +'%b %d') 󰃭"

# Right edge padding
OUTPUT+="  "

echo "$OUTPUT"
