#!/usr/bin/env bash
# agent_status.sh - tmux status segment: one dot per Claude Code pane, in any
# session, coloured by state. Matches the Starship-style Nordic theme.
#
# A pane is a Claude pane when its title is in one of the two formats Claude
# writes, whatever the session is called:
#   peon-ping  "●<project>: ready|working|done|needs approval"
#   native     "✳ <task>" when idle, a braille spinner frame when busy
# The process name is not enough: wrappers such as claude-bedrock run claude as
# a child of zsh, so pane_current_command reads "zsh".

# -u and a printable delimiter: in a non-UTF-8 locale (env -i, some mosh
# shells) the tmux client rewrites tabs and non-ASCII to "_". Title is last, so
# a "|" inside it lands intact in $title.
panes=$(tmux -u list-panes -a -F '#{session_name}|#{window_index}|#{pane_current_command}|#{pane_title}' 2>/dev/null) || exit 0
[[ -z "$panes" ]] && exit 0

agents=""
attention=0
total=0

while IFS='|' read -r session window command title; do
    if [[ "$title" == *": needs approval" ]]; then
        color="#bf616a"; icon="●"; ((attention++))   # red - blocked on you
    elif [[ "$title" == *": done" ]]; then
        color="#ebcb8b"; icon="●"; ((attention++))   # yellow - review
    elif [[ "$title" == *": ready" ]]; then
        color="#88c0d0"; icon="●"                    # cyan - waiting for first input
    elif [[ "$title" == *": working" || "$title" =~ ^[⠀-⣿]\  ]]; then
        color="#a3be8c"; icon="◉"                    # green - busy
    elif [[ "$title" == "✳ "* || "$command" == "claude" ]]; then
        color="#81a1c1"; icon="○"                    # blue - idle
    else
        continue                                     # not a Claude pane
    fi

    name="$session:$window"
    [[ ${#name} -gt 16 ]] && name="${name:0:14}.."

    agents+="#[fg=${color}]${icon} ${name} "
    ((total++))
done <<< "$panes"

[[ $total -eq 0 ]] && exit 0

if [[ $attention -gt 0 ]]; then
    printf '#[fg=#ebcb8b,bold]󰚩 #[nobold]%s' "$agents"
else
    printf '#[fg=#a3be8c]󰚩 %s' "$agents"
fi
