#!/usr/bin/env bash
# Tmux Chezmoi Status Script
# Shows chezmoi status in tmux status bar

set -e

# Colors for tmux status bar (Nordic theme)
CHEZMOI_COLOR="#bf616a"  # Red for changes
OK_COLOR="#a3be8c"       # Green for OK
TEXT_COLOR="#2e3440"     # Dark text

# Check if chezmoi is available
if ! command -v chezmoi >/dev/null 2>&1; then
    exit 0
fi

# Get chezmoi status (suppress stderr to avoid tmux spam)
chezmoi_status=$(chezmoi status 2>/dev/null || echo "")

# Check git status in chezmoi source directory
chezmoi_source="${HOME}/.local/share/chezmoi"
git_changes=""

if [[ -d "$chezmoi_source" ]]; then
    cd "$chezmoi_source" 2>/dev/null || exit 0
    git_changes=$(git status --porcelain 2>/dev/null || echo "")
fi

# Determine status and output
if [[ -n "$chezmoi_status" ]] || [[ -n "$git_changes" ]]; then
    # Count changes
    change_count=0
    if [[ -n "$chezmoi_status" ]]; then
        change_count=$(echo "$chezmoi_status" | wc -l | tr -d ' ')
    fi
    
    git_count=0
    if [[ -n "$git_changes" ]]; then
        git_count=$(echo "$git_changes" | wc -l | tr -d ' ')
    fi
    
    total_changes=$((change_count + git_count))
    
    # Format output for tmux status bar
    if [[ $total_changes -eq 1 ]]; then
        echo "#[bg=$CHEZMOI_COLOR,fg=$TEXT_COLOR,bold] 📝 $total_changes #[bg=$CHEZMOI_COLOR,fg=#4c566a]"
    else
        echo "#[bg=$CHEZMOI_COLOR,fg=$TEXT_COLOR,bold] 📝 $total_changes #[bg=$CHEZMOI_COLOR,fg=#4c566a]"
    fi
else
    # Optional: Show OK status (comment out if you prefer minimal)
    # echo "#[bg=$OK_COLOR,fg=$TEXT_COLOR] ✓ #[bg=$OK_COLOR,fg=#4c566a]"
    
    # Minimal: show nothing when everything is OK
    echo ""
fi