# Shell Aliases

# Modern replacements
alias vi="nvim"
alias ls="eza"

# Enhanced ls variations with eza
alias ll="eza --icons --long --all --group --header --git"
alias la="eza --icons --long --all --group --header --binary --links --inode --blocks"
alias ld="eza --icons --long --all --group --header --list-dirs"
alias lg="eza --icons --long --all --group --header --git"
alias le="eza --icons --long --all --group --header --extended"
alias lt="eza --icons --long --all --group --header --tree --level"

# Modern CLI tools (if available)
if command -v bat >/dev/null 2>&1; then
    alias cat="bat"
fi

if command -v fd >/dev/null 2>&1; then
    alias find="fd"
fi

if command -v rg >/dev/null 2>&1; then
    alias grep="rg"
fi

# Tmux session management
alias tmux-cleanup='tmux list-sessions | grep -E "^[0-9]+:" | cut -d: -f1 | xargs -I {} tmux kill-session -t {}'
alias tmux-list='tmux list-sessions'
alias tmux-kill-all='tmux kill-server'
alias ta='tmux attach-session -t'
alias tn='tmux new-session -s'
alias tl='tmux list-sessions'