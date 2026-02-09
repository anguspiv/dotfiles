#!/bin/zsh
# Smart shell launcher for Ghostty
# - Default: Launch tmux session
# - Set GHOSTTY_NO_TMUX=1 to skip tmux

if [[ "$GHOSTTY_NO_TMUX" == "1" ]]; then
    # Launch regular shell without tmux
    exec "${SHELL:-/bin/zsh}"
else
    # Launch tmux session (default)
    exec "${HOME}/.config/zed/tmux-session.sh" "$@"
fi
