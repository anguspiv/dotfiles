#!/usr/bin/env bash
# sesh_pick.sh - prefix + T. One fzf popup over running tmux sessions, zoxide
# directories and the repos in ~/workspace and ~/projects; sesh attaches to the
# matching session or creates one named after the directory.
#
#   ^a all   ^t tmux sessions   ^x zoxide   ^w repos   ^d kill session

repos() { fd -d 1 -t d . "$HOME/workspace" "$HOME/projects" 2>/dev/null | sed 's:/$::'; }
export -f repos

pick=$(
    sesh list --icons | fzf-tmux -p 80%,70% \
        --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
        --header '  ^a all ^t tmux ^x zoxide ^w repos ^d kill' \
        --bind 'tab:down,btab:up' \
        --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
        --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
        --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
        --bind 'ctrl-w:change-prompt(  )+reload(bash -c repos)' \
        --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
        --preview-window 'right:55%' \
        --preview 'sesh preview {}'
)
[[ -n "$pick" ]] && sesh connect "$pick"
exit 0
