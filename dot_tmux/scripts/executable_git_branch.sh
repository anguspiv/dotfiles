#!/usr/bin/env bash
# Git branch indicator for current pane directory

# Cache for performance
CACHE_FILE="/tmp/tmux_git_branch_$$"
CACHE_TTL=5  # 5 seconds

# Check cache
if [[ -f "$CACHE_FILE" ]]; then
    CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [[ $CACHE_AGE -lt $CACHE_TTL ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Get current pane directory (passed as argument or use pwd)
PANE_DIR="${1:-$(pwd)}"

# Check if we're in a git repo
if cd "$PANE_DIR" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
    # Get branch name
    BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

    # Check if there are changes
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        # Has changes
        OUTPUT=" ${BRANCH}*"
    else
        # Clean
        OUTPUT=" ${BRANCH}"
    fi
else
    OUTPUT=""
fi

# Cache result
echo "$OUTPUT" > "$CACHE_FILE"
echo "$OUTPUT"
