#!/usr/bin/env bash
# claude_jump.sh - prefix + a. Jump to the next Claude Code pane that needs
# you, in any session: "needs approval" first, then "done". Pressing it again
# moves on to the next one, so it cycles rather than sticking on one pane.
# States come from peon-ping's pane titles, as in agent_status.sh.

current=$(tmux display-message -p '#{pane_id}')
# -u and "|": see agent_status.sh (non-UTF-8 clients rewrite tabs and non-ASCII)
panes=$(tmux -u list-panes -a -F '#{pane_id}|#{pane_title}' 2>/dev/null) || exit 0

for state in "needs approval" "done"; do
    matches=$(printf '%s\n' "$panes" | awk -F'|' -v s=": $state" \
        'substr($0, length($0) - length(s) + 1) == s { print $1 }')
    [[ -z "$matches" ]] && continue
    # First match after the current pane, wrapping round to the first
    next=$(printf '%s\n' "$matches" | awk -v cur="$current" \
        'NR == 1 { first = $0 } seen { print; found = 1; exit } $0 == cur { seen = 1 }
         END { if (!found) print first }')
    if [[ "$next" != "$current" ]]; then
        tmux switch-client -t "$next"
        exit 0
    fi
done

tmux display-message "No other Claude pane needs you"
