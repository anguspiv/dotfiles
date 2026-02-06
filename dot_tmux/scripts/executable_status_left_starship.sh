#!/usr/bin/env bash
# Starship-style left status with Nerd Font icons

PANE_DIR="${1:-$(pwd)}"
OUTPUT=""

# Session (always show with terminal icon)
SESSION=$(tmux display-message -p '#S')
OUTPUT+="#[fg=#88c0d0,bold] ${SESSION}  "

# Directory (always show with folder icon on left)
DIR_NAME=$(basename "$PANE_DIR")
if [[ "$PANE_DIR" == "$HOME" ]]; then
    OUTPUT+="#[fg=#81a1c1,bold] ~  "
else
    OUTPUT+="#[fg=#81a1c1,bold] ${DIR_NAME}  "
fi

# Git (show with branch icon on left)
if cd "$PANE_DIR" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        OUTPUT+="#[fg=#b48ead,bold] ${BRANCH} ✗  "
    else
        OUTPUT+="#[fg=#b48ead,bold] ${BRANCH}  "
    fi
fi

# Version (show with language icon on left when detected)
if [[ -f "package.json" ]] && command -v node >/dev/null 2>&1; then
    VERSION=$(node -v 2>/dev/null)
    OUTPUT+="#[fg=#a3be8c] ${VERSION}  "
elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]] || [[ -n "$VIRTUAL_ENV" ]]; then
    if command -v python3 >/dev/null 2>&1; then
        VERSION=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1-2)
        OUTPUT+="#[fg=#a3be8c] ${VERSION}  "
    fi
elif [[ -f "Cargo.toml" ]] && command -v rustc >/dev/null 2>&1; then
    VERSION=$(rustc --version 2>/dev/null | awk '{print $2}')
    OUTPUT+="#[fg=#a3be8c] ${VERSION}  "
elif [[ -f "go.mod" ]] && command -v go >/dev/null 2>&1; then
    VERSION=$(go version 2>/dev/null | awk '{print $3}')
    OUTPUT+="#[fg=#a3be8c] ${VERSION}  "
fi

echo "$OUTPUT"
