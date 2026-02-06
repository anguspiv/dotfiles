#!/usr/bin/env bash
# Starship-style system stats

if [[ "$OSTYPE" == "darwin"* ]]; then
    CPU=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')
    MEM=$(ps -A -o %mem | awk '{s+=$1} END {printf "%.0f", s}')
else
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)
    MEM=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
fi

# CPU color
if [[ $CPU -ge 80 ]]; then
    CPU_COLOR="#bf616a"
elif [[ $CPU -ge 50 ]]; then
    CPU_COLOR="#ebcb8b"
else
    CPU_COLOR="#a3be8c"
fi

# MEM color
if [[ $MEM -ge 80 ]]; then
    MEM_COLOR="#bf616a"
elif [[ $MEM -ge 60 ]]; then
    MEM_COLOR="#ebcb8b"
else
    MEM_COLOR="#a3be8c"
fi

echo "#[fg=$CPU_COLOR] ${CPU}% #[fg=$MEM_COLOR] ${MEM}% "
