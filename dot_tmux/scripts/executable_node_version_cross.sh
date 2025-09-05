#!/bin/bash
# Cross-platform Node version detection
# Supports fnm, nvm, and direct node installation

CACHE_FILE="/tmp/tmux_node_version_$$"
CACHE_TTL=60  # Cache for 60 seconds

# Check if cache is valid
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [ $CACHE_AGE -lt $CACHE_TTL ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

get_node_version() {
    # Method 1: Direct node command (works with any Node.js installation)
    if command -v node >/dev/null 2>&1; then
        local version=$(node -v 2>/dev/null | cut -c2-)
        if [ -n "$version" ]; then
            echo "node-$version"
            return
        fi
    fi
    
    # Method 2: fnm (Fast Node Manager)
    if command -v fnm >/dev/null 2>&1; then
        local version=$(fnm current 2>/dev/null)
        if [ -n "$version" ] && [ "$version" != "none" ]; then
            echo "node-$version"
            return
        fi
    fi
    
    # Method 3: nvm (Node Version Manager)
    if [ -n "$NVM_DIR" ] && [ -f "$NVM_DIR/nvm.sh" ]; then
        source "$NVM_DIR/nvm.sh" >/dev/null 2>&1
        local version=$(nvm current 2>/dev/null | cut -c2-)
        if [ -n "$version" ] && [ "$version" != "system" ] && [ "$version" != "none" ]; then
            echo "node-$version"
            return
        fi
    fi
    
    # Method 4: Check common installation paths
    for node_path in /usr/local/bin/node /usr/bin/node ~/.local/bin/node; do
        if [ -x "$node_path" ]; then
            local version=$("$node_path" -v 2>/dev/null | cut -c2-)
            if [ -n "$version" ]; then
                echo "node-$version"
                return
            fi
        fi
    done
    
    echo "no-node"
}

get_node_version | tee "$CACHE_FILE"