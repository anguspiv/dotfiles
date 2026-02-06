#!/usr/bin/env bash
# Starship-style left status - all in one for consistent formatting

PANE_DIR="${1:-$(pwd)}"
OUTPUT=""

# Thin powerline arrow character (U+E0B1) for left side (unfilled backgrounds)
ARROW=$(printf '\xee\x82\xb1')

# Left edge padding
OUTPUT+="  "

# Session (always show) - tmux icon (U+F26C)
SESSION=$(tmux display-message -p '#S')
OUTPUT+="#[fg=#88c0d0,bold]$(printf '\xef\x89\xac') ${SESSION}"

# Arrow matching session color
OUTPUT+=" #[fg=#88c0d0]${ARROW} "

# Directory (always show with icon on left) - folder icon (U+F07C)
DIR_NAME=$(basename "$PANE_DIR")
if [[ "$PANE_DIR" == "$HOME" ]]; then
    OUTPUT+="#[fg=#81a1c1,bold]$(printf '\xef\x81\xbc') ~"
else
    OUTPUT+="#[fg=#81a1c1,bold]$(printf '\xef\x81\xbc') ${DIR_NAME}"
fi

# Arrow matching directory color
OUTPUT+=" #[fg=#81a1c1]${ARROW} "

# Git (show with icon on left, or show "no git" placeholder) - git branch icon (U+E0A0)
if cd "$PANE_DIR" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        OUTPUT+="#[fg=#b48ead,bold]$(printf '\xee\x82\xa0') ${BRANCH} ✗"
        # Arrow matching git color
        OUTPUT+=" #[fg=#b48ead]${ARROW} "
    else
        OUTPUT+="#[fg=#b48ead,bold]$(printf '\xee\x82\xa0') ${BRANCH}"
        # Arrow matching git color
        OUTPUT+=" #[fg=#b48ead]${ARROW} "
    fi
fi

# Version (show with language-specific icon on left when detected)
if [[ -f "package.json" ]] && command -v node >/dev/null 2>&1; then
    VERSION=$(node -v 2>/dev/null)
    # Node icon (U+E718)
    OUTPUT+="#[fg=#a3be8c]$(printf '\xee\x9c\x98') ${VERSION}"
    # Arrow matching version color
    OUTPUT+=" #[fg=#a3be8c]${ARROW} "
elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]] || [[ -n "$VIRTUAL_ENV" ]]; then
    if command -v python3 >/dev/null 2>&1; then
        VERSION=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1-2)
        # Python icon (U+E73C)
        OUTPUT+="#[fg=#a3be8c]$(printf '\xee\x9c\xbc') ${VERSION}"
        # Arrow matching version color
        OUTPUT+=" #[fg=#a3be8c]${ARROW} "
    fi
elif [[ -f "Cargo.toml" ]] && command -v rustc >/dev/null 2>&1; then
    VERSION=$(rustc --version 2>/dev/null | awk '{print $2}')
    # Rust icon (U+E7A8)
    OUTPUT+="#[fg=#a3be8c]$(printf '\xee\x9e\xa8') ${VERSION}"
    # Arrow matching version color
    OUTPUT+=" #[fg=#a3be8c]${ARROW} "
elif [[ -f "go.mod" ]] && command -v go >/dev/null 2>&1; then
    VERSION=$(go version 2>/dev/null | awk '{print $3}')
    # Go icon (U+E626)
    OUTPUT+="#[fg=#a3be8c]$(printf '\xee\x98\xa6') ${VERSION}"
    # Arrow matching version color
    OUTPUT+=" #[fg=#a3be8c]${ARROW} "
fi

# Right edge padding
OUTPUT+="  "

echo "$OUTPUT"
