#!/usr/bin/env bash
# Starship-style directory display

PANE_DIR="${1:-$(pwd)}"
DIR_NAME=$(basename "$PANE_DIR")

# Use home icon if in home directory
if [[ "$PANE_DIR" == "$HOME" ]]; then
    echo "  ~"
else
    echo "  ${DIR_NAME}"
fi
