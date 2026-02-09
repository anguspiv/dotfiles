#!/usr/bin/env bash
# Starship-style git indicator with icon

CACHE_FILE="/tmp/tmux_git_$$"
CACHE_TTL=5

if [[ -f "$CACHE_FILE" ]]; then
    CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [[ $CACHE_AGE -lt $CACHE_TTL ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

PANE_DIR="${1:-$(pwd)}"

if cd "$PANE_DIR" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

    # Check for changes
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        OUTPUT="  ${BRANCH} [✗]"
    else
        OUTPUT="  ${BRANCH}"
    fi
else
    OUTPUT=""
fi

echo "$OUTPUT" > "$CACHE_FILE"
echo "$OUTPUT"
