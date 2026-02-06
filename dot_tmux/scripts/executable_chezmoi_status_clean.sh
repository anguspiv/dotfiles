#!/usr/bin/env bash
# Clean chezmoi status - Spaceship style

command -v chezmoi >/dev/null 2>&1 || exit 0

CACHE_FILE="${HOME}/.cache/tmux_chezmoi_status"
CACHE_TTL=300

if [[ -f "$CACHE_FILE" ]]; then
    CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [[ $CACHE_AGE -lt $CACHE_TTL ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

LOCAL_CHANGES=$(chezmoi status 2>/dev/null | wc -l | tr -d ' ')

if [[ "$LOCAL_CHANGES" -gt 0 ]]; then
    OUTPUT="#[fg=#ebcb8b] ${LOCAL_CHANGES} #[fg=#616e88]│ "
else
    OUTPUT="#[fg=#a3be8c]󰄬 #[fg=#616e88]│ "
fi

mkdir -p "$(dirname "$CACHE_FILE")"
echo "$OUTPUT" > "$CACHE_FILE"
echo "$OUTPUT"
