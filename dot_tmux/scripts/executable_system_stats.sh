#!/bin/bash
# Fast CPU and memory stats
# Optimized for minimal overhead

CACHE_FILE="/tmp/tmux_system_$$"
CACHE_TTL=5  # Cache for 5 seconds (more frequent for system stats)

# Check cache
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [ $CACHE_AGE -lt $CACHE_TTL ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Get CPU usage (more accurate method for macOS)
CPU_USAGE=$(top -l 2 -n 0 -F | grep "CPU usage" | tail -1 | awk '{print $3}' | cut -d% -f1 | cut -d. -f1)

# Get memory usage (efficient method)
MEM_INFO=$(vm_stat 2>/dev/null)
if [ -n "$MEM_INFO" ]; then
    PAGE_SIZE=$(vm_stat | head -1 | grep -o '[0-9]*')
    FREE_PAGES=$(echo "$MEM_INFO" | awk '/Pages free:/ {print $3}' | tr -d '.')
    INACTIVE_PAGES=$(echo "$MEM_INFO" | awk '/Pages inactive:/ {print $3}' | tr -d '.')
    
    TOTAL_MEM=$(sysctl -n hw.memsize)
    AVAILABLE_MEM=$(( (FREE_PAGES + INACTIVE_PAGES) * PAGE_SIZE ))
    USED_MEM=$(( TOTAL_MEM - AVAILABLE_MEM ))
    MEM_PERCENT=$(( USED_MEM * 100 / TOTAL_MEM ))
else
    MEM_PERCENT=0
fi

# Format output with warning indicators
CPU_ICON="󰻠"
MEM_ICON="󰍛"

# Add warning colors (will be styled in tmux config)
if [ "$CPU_USAGE" -gt 80 ]; then
    CPU_ICON="⚠"
fi

if [ "$MEM_PERCENT" -gt 80 ]; then
    MEM_ICON="⚠"
fi

echo "${CPU_ICON}${CPU_USAGE}% ${MEM_ICON}${MEM_PERCENT}%" | tee "$CACHE_FILE"