#!/usr/bin/env bash
# Enhanced chezmoi status for tmux statusline
# Shows: pending changes, remote updates, last sync time

# Quick exit if chezmoi not installed
command -v chezmoi >/dev/null 2>&1 || exit 0

# Cache file for performance
CACHE_FILE="${HOME}/.cache/tmux_chezmoi_status"
CACHE_TTL=300  # 5 minutes

# Check cache
if [[ -f "$CACHE_FILE" ]]; then
    CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [[ $CACHE_AGE -lt $CACHE_TTL ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Build status string
STATUS=""
ICON=""
COLOR=""

# Check local changes
LOCAL_CHANGES=$(chezmoi status 2>/dev/null | wc -l | tr -d ' ')
if [[ "$LOCAL_CHANGES" -gt 0 ]]; then
    ICON="📝"
    COLOR="#ebcb8b"  # Yellow/orange
    STATUS="$LOCAL_CHANGES"
fi

# Check remote updates (quick check, may not be 100% accurate)
if cd "$HOME/.local/share/chezmoi" 2>/dev/null; then
    # Only fetch if last fetch was >30 minutes ago
    LAST_FETCH=$(stat -f %m .git/FETCH_HEAD 2>/dev/null || echo 0)
    NOW=$(date +%s)
    if [[ $((NOW - LAST_FETCH)) -gt 1800 ]]; then
        git fetch --quiet 2>/dev/null &
    fi

    BEHIND=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
    if [[ "$BEHIND" -gt 0 ]]; then
        if [[ -n "$STATUS" ]]; then
            STATUS="$STATUS↓$BEHIND"
        else
            ICON="⬇️"
            COLOR="#5e81ac"  # Blue
            STATUS="$BEHIND"
        fi
    fi
    cd - >/dev/null
fi

# Output formatted for tmux
if [[ -n "$STATUS" ]]; then
    OUTPUT="#[bg=#2e3440,fg=#4c566a]#[bg=#4c566a,fg=$COLOR] $ICON $STATUS "
else
    # All synced
    OUTPUT="#[bg=#2e3440,fg=#4c566a]#[bg=#4c566a,fg=#a3be8c] ✓ "
fi

# Cache result
mkdir -p "$(dirname "$CACHE_FILE")"
echo "$OUTPUT" > "$CACHE_FILE"

echo "$OUTPUT"
