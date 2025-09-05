#!/bin/bash
# Fast Node version detection via fnm
# Uses cache to avoid repeated fnm calls

CACHE_FILE="/tmp/tmux_node_version_$$"
CACHE_TTL=60  # Cache for 60 seconds

# Check if cache is valid
if [ -f "$CACHE_FILE" ]; then
    CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [ $CACHE_AGE -lt $CACHE_TTL ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Get node version efficiently
if command -v node >/dev/null 2>&1; then
    VERSION=$(node -v 2>/dev/null | cut -c2-)
    if [ -n "$VERSION" ]; then
        echo "node-$VERSION" | tee "$CACHE_FILE"
    else
        echo "no-node" | tee "$CACHE_FILE"
    fi
else
    echo "no-node" | tee "$CACHE_FILE"
fi