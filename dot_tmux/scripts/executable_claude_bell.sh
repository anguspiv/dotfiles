#!/usr/bin/env bash
# claude_bell.sh - Claude Code hook (Notification, Stop) that rings the bell in
# Claude's own tmux pane, so monitor-bell flags that window in the status bar.
#
# Not preferredNotifChannel=terminal_bell: that would replace the native
# Ghostty notification Claude sends on "auto". Writing BEL to the pane's tty
# directly gives both. Hooks have no controlling terminal, hence the tty lookup.
#
# No-op outside tmux. Always exits 0 so it can never block Claude.

[[ -n "${TMUX_PANE:-}" ]] || exit 0
tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null) || exit 0
[[ -w "$tty" ]] && printf '\a' > "$tty"
exit 0
