#!/bin/bash
# Cross-platform CPU and memory stats
# Supports macOS and Linux with minimal overhead

CACHE_FILE="/tmp/tmux_system_$$"
CACHE_TTL=5  # Cache for 5 seconds (more frequent for system stats)

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

get_stats_macos() {
    # Get CPU usage
    local cpu_usage=$(top -l 2 -n 0 -F | grep "CPU usage" | tail -1 | awk '{print $3}' | cut -d% -f1 | cut -d. -f1)
    
    # Get memory usage
    local mem_info=$(vm_stat 2>/dev/null)
    local mem_percent=0
    
    if [ -n "$mem_info" ]; then
        local page_size=$(vm_stat | head -1 | grep -o '[0-9]*')
        local free_pages=$(echo "$mem_info" | awk '/Pages free:/ {print $3}' | tr -d '.')
        local inactive_pages=$(echo "$mem_info" | awk '/Pages inactive:/ {print $3}' | tr -d '.')
        
        local total_mem=$(sysctl -n hw.memsize)
        local available_mem=$(( (free_pages + inactive_pages) * page_size ))
        local used_mem=$(( total_mem - available_mem ))
        mem_percent=$(( used_mem * 100 / total_mem ))
    fi
    
    echo "$cpu_usage" "$mem_percent"
}

get_stats_linux() {
    local cpu_usage=0
    local mem_percent=0
    
    # Get CPU usage - multiple methods
    if [ -f /proc/stat ]; then
        # Method 1: /proc/stat (most reliable)
        local cpu_line=$(grep '^cpu ' /proc/stat)
        sleep 0.1  # Brief pause for accurate measurement
        local cpu_line2=$(grep '^cpu ' /proc/stat)
        
        if [ -n "$cpu_line" ] && [ -n "$cpu_line2" ]; then
            local cpu1=($(echo $cpu_line))
            local cpu2=($(echo $cpu_line2))
            
            local idle1=${cpu1[4]}
            local idle2=${cpu2[4]}
            
            local total1=0
            local total2=0
            for i in {1..7}; do
                total1=$((total1 + ${cpu1[i]:-0}))
                total2=$((total2 + ${cpu2[i]:-0}))
            done
            
            local idle_diff=$((idle2 - idle1))
            local total_diff=$((total2 - total1))
            
            if [ $total_diff -gt 0 ]; then
                cpu_usage=$((100 - (idle_diff * 100 / total_diff)))
            fi
        fi
    else
        # Fallback: uptime method (less accurate but fast)
        local load=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs)
        cpu_usage=$(echo "$load * 100" | bc 2>/dev/null | cut -d. -f1 || echo "0")
    fi
    
    # Get memory usage from /proc/meminfo
    if [ -f /proc/meminfo ]; then
        local mem_total=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
        local mem_available=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
        
        # Fallback if MemAvailable is not present
        if [ -z "$mem_available" ]; then
            local mem_free=$(awk '/MemFree:/ {print $2}' /proc/meminfo)
            local buffers=$(awk '/Buffers:/ {print $2}' /proc/meminfo)
            local cached=$(awk '/Cached:/ {print $2}' /proc/meminfo)
            mem_available=$((mem_free + buffers + cached))
        fi
        
        if [ $mem_total -gt 0 ]; then
            local mem_used=$((mem_total - mem_available))
            mem_percent=$((mem_used * 100 / mem_total))
        fi
    fi
    
    echo "$cpu_usage" "$mem_percent"
}

format_output() {
    local cpu_usage=$1
    local mem_percent=$2

    # Choose CPU icon based on usage
    local cpu_icon="󰻠"
    if [ "$cpu_usage" -gt 80 ]; then
        cpu_icon="󰀪"  # Warning icon for high CPU
    fi

    # Choose memory icon based on usage
    local mem_icon="󰍛"
    if [ "$mem_percent" -gt 80 ]; then
        mem_icon="󰀪"  # Warning icon for high memory
    fi

    echo "${cpu_icon}${cpu_usage}% ${mem_icon}${mem_percent}%"
}

# Main execution
case $OS in
    macos)
        stats=($(get_stats_macos))
        ;;
    linux)
        stats=($(get_stats_linux))
        ;;
    *)
        stats=(0 0)
        ;;
esac

cpu_usage=${stats[0]:-0}
mem_percent=${stats[1]:-0}

format_output "$cpu_usage" "$mem_percent" | tee "$CACHE_FILE"