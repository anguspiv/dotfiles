#!/usr/bin/env bash
# Clean system stats - Spaceship style

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CPU=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')
    MEM=$(ps -A -o %mem | awk '{s+=$1} END {printf "%.0f", s}')
else
    # Linux
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)
    MEM=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
fi

# CPU color based on load
if [[ $CPU -ge 80 ]]; then
    CPU_COLOR="#bf616a"  # Red
elif [[ $CPU -ge 50 ]]; then
    CPU_COLOR="#ebcb8b"  # Yellow
else
    CPU_COLOR="#a3be8c"  # Green
fi

# MEM color based on usage
if [[ $MEM -ge 80 ]]; then
    MEM_COLOR="#bf616a"  # Red
elif [[ $MEM -ge 60 ]]; then
    MEM_COLOR="#ebcb8b"  # Yellow
else
    MEM_COLOR="#a3be8c"  # Green
fi

echo "#[fg=$CPU_COLOR] ${CPU}% #[fg=$MEM_COLOR] ${MEM}% "
