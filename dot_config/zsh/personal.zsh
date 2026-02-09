# Personal-specific Zsh Configuration
# This file is only loaded on personal machines

# =====================================================
# PERSONAL ENVIRONMENT
# =====================================================
export PERSONAL_CONTEXT=true

# Personal project paths
export PERSONAL_PROJECTS="$HOME/projects"
export LEARNING_DIR="$HOME/learning"
export PLAYGROUND_DIR="$HOME/playground"

# =====================================================
# PERSONAL ALIASES
# =====================================================

# Quick navigation
alias proj="cd $PERSONAL_PROJECTS"
alias learn="cd $LEARNING_DIR"
alias play="cd $PLAYGROUND_DIR"

# Personal git configuration
personal_git_config() {
    git config user.email "{{ .personalEmail }}"
    {{- if .signingkey }}
    git config user.signingkey "{{ .signingkey }}"
    git config commit.gpgsign true
    {{- end }}
    echo "✅ Git configured for personal ({{ .personalEmail }})"
}

# Development shortcuts
alias dev="npm run dev"
alias build="npm run build"
alias test="npm run test"
alias lint="npm run lint"

# Docker cleanup for personal projects
alias docker-cleanup="docker system prune -af --volumes"
alias docker-stop-all="docker stop $(docker ps -aq) 2>/dev/null"

# =====================================================
# PERSONAL FUNCTIONS
# =====================================================

# Create new project
newproject() {
    local name="${1:-}"
    if [[ -z "$name" ]]; then
        echo "Usage: newproject <project-name>"
        return 1
    fi

    local project_dir="$PERSONAL_PROJECTS/$name"
    mkdir -p "$project_dir"
    cd "$project_dir"

    # Initialize git
    git init
    git config user.email "{{ .personalEmail }}"

    # Create README
    cat > README.md <<EOF
# $name

Created: $(date +%Y-%m-%d)

## Description

## Setup

## Usage
EOF

    echo "✅ Created new project: $name"
    ${EDITOR:-nvim} README.md
}

# Learning journal
learn_note() {
    local topic="${1:-general}"
    local date=$(date +%Y-%m-%d)
    local notes_dir="$LEARNING_DIR/notes"
    local notes_file="$notes_dir/$topic-$date.md"

    mkdir -p "$notes_dir"

    if [[ ! -f "$notes_file" ]]; then
        cat > "$notes_file" <<EOF
# Learning: $topic
Date: $date

## Key Concepts

## Code Examples

## Resources

## Next Steps
EOF
    fi

    ${EDITOR:-nvim} "$notes_file"
}

# Quick experiment/playground
playground() {
    local name="${1:-experiment-$(date +%s)}"
    local play_dir="$PLAYGROUND_DIR/$name"

    mkdir -p "$play_dir"
    cd "$play_dir"

    echo "🎮 Playground created: $name"
    echo "Location: $play_dir"
}

# GitHub operations
gh_clone_mine() {
    if ! command -v gh >/dev/null 2>&1; then
        echo "GitHub CLI not installed"
        return 1
    fi

    gh repo list --limit 100 | fzf | awk '{print $1}' | xargs -I {} gh repo clone {}
}

gh_new_repo() {
    local name="${1:-}"
    if [[ -z "$name" ]]; then
        echo "Usage: gh_new_repo <repo-name>"
        return 1
    fi

    gh repo create "$name" --private --clone
    cd "$name"
}

# =====================================================
# AI TOOLS FOR PERSONAL USE
# =====================================================

{{- if .features.ai_tools }}
# Claude Code helpers
claude_review() {
    local file="${1:-.}"
    claude "Review this code for improvements" "$file"
}

claude_explain() {
    local file="${1:-.}"
    claude "Explain how this code works" "$file"
}

claude_optimize() {
    local file="${1:-.}"
    claude "Suggest optimizations for this code" "$file"
}
{{- end }}

# =====================================================
# PERSONAL PROJECT MANAGEMENT
# =====================================================

# List personal projects
list_projects() {
    echo "📦 Personal Projects:"
    ls -1 "$PERSONAL_PROJECTS" 2>/dev/null || echo "No projects found"

    echo "\n📚 Learning Projects:"
    ls -1 "$LEARNING_DIR" 2>/dev/null || echo "No learning projects found"

    echo "\n🎮 Playground:"
    ls -1 "$PLAYGROUND_DIR" 2>/dev/null || echo "No playground experiments"
}

# Quick project switcher with tmux
project() {
    local name="${1:-}"

    if [[ -z "$name" ]]; then
        # Use fzf to select if available
        if command -v fzf >/dev/null 2>&1; then
            name=$(ls -1 "$PERSONAL_PROJECTS" | fzf --prompt="Select project: ")
        else
            list_projects
            return
        fi
    fi

    [[ -z "$name" ]] && return

    local project_dir="$PERSONAL_PROJECTS/$name"
    if [[ -d "$project_dir" ]]; then
        cd "$project_dir"

        # Start tmux session
        if [[ -z "$TMUX" ]] && command -v tmux >/dev/null 2>&1; then
            tmux new-session -A -s "personal-$name"
        fi
    else
        echo "Project not found: $name"
    fi
}

# Archive old projects
archive_project() {
    local name="${1:-}"
    if [[ -z "$name" ]]; then
        echo "Usage: archive_project <project-name>"
        return 1
    fi

    local project_dir="$PERSONAL_PROJECTS/$name"
    local archive_dir="$HOME/archive/projects"

    if [[ ! -d "$project_dir" ]]; then
        echo "Project not found: $name"
        return 1
    fi

    mkdir -p "$archive_dir"
    mv "$project_dir" "$archive_dir/"
    echo "📦 Archived: $name → $archive_dir/$name"
}

# =====================================================
# PERSONAL REMINDERS & PRODUCTIVITY
# =====================================================

# Daily reminder to review notes
if [[ $(date +%H) -eq 9 ]] && [[ ! -f /tmp/.morning_reminder_shown ]]; then
    echo "☀️  Good morning! Check your learning notes: learn_note"
    touch /tmp/.morning_reminder_shown
fi

# Quick todo (simple text-based)
todo() {
    local todo_file="$HOME/.todo.md"

    if [[ $# -eq 0 ]]; then
        # Show todos
        if [[ -f "$todo_file" ]]; then
            cat "$todo_file"
        else
            echo "No todos. Use: todo add <item>"
        fi
    elif [[ "$1" == "add" ]]; then
        shift
        echo "- [ ] $*" >> "$todo_file"
        echo "✅ Added todo"
    elif [[ "$1" == "done" ]]; then
        ${EDITOR:-nvim} "$todo_file"
    fi
}
