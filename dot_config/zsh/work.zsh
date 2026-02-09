# Work-specific Zsh Configuration
# This file is only loaded on work machines

# =====================================================
# WORK ENVIRONMENT
# =====================================================
export WORK_CONTEXT=true

# Company-specific paths
export COMPANY_TOOLS="/opt/company-tools"
export WORK_PROJECTS="$HOME/work"

# =====================================================
# WORK ALIASES
# =====================================================

# Quick project navigation
alias cdwork="cd $WORK_PROJECTS"
alias cdtool="cd $COMPANY_TOOLS"

# Work-specific git configuration
work_git_config() {
    git config user.email "{{ .workEmail }}"
    {{- if .signingkey }}
    git config user.signingkey "{{ .signingkey }}"
    git config commit.gpgsign true
    {{- end }}
    echo "✅ Git configured for work ({{ .workEmail }})"
}

# VPN helpers (if configured)
{{- if ne .secrets.work.vpn_config "" }}
alias vpn-connect="sudo openconnect {{ .secrets.work.vpn_config }}"
alias vpn-status="ps aux | grep openconnect"
{{- end }}

# Work-specific services
alias logs-work="tail -f /var/log/work/*.log"

# Company-specific shortcuts
{{- if ne .secrets.work.jira_token "" }}
alias jira-open="open https://jira.your-company.com/browse/"
{{- end }}

{{- if ne .secrets.work.confluence_host "" }}
alias wiki="open {{ .secrets.work.confluence_host }}"
{{- end }}

# =====================================================
# WORK FUNCTIONS
# =====================================================

# Quick standup notes
standup() {
    local date=$(date +%Y-%m-%d)
    local notes_file="$HOME/work/notes/standup-$date.md"
    mkdir -p "$(dirname "$notes_file")"

    if [[ ! -f "$notes_file" ]]; then
        cat > "$notes_file" <<EOF
# Standup Notes - $date

## Yesterday
-

## Today
-

## Blockers
- None

## Notes
-
EOF
    fi

    ${EDITOR:-nvim} "$notes_file"
}

# Work project switcher
workproject() {
    local project="${1:-}"
    if [[ -z "$project" ]]; then
        echo "Available projects:"
        ls -1 "$WORK_PROJECTS"
        return
    fi

    local project_dir="$WORK_PROJECTS/$project"
    if [[ -d "$project_dir" ]]; then
        cd "$project_dir"
        # Start tmux session if not in one
        if [[ -z "$TMUX" ]] && command -v tmux >/dev/null 2>&1; then
            tmux new-session -A -s "work-$project"
        fi
    else
        echo "Project not found: $project"
    fi
}

# Compliance check before commits (example)
pre-commit-check() {
    echo "🔍 Running work compliance checks..."
    # Add your company's compliance checks here
    # Example: check for secrets, PII, etc.

    # Check for common secret patterns
    if git diff --cached | grep -iE '(password|api_key|secret|token)\s*=\s*["\x27]'; then
        echo "⚠️  Warning: Potential secrets detected in staged changes"
        echo "Please review before committing"
        return 1
    fi

    echo "✅ Compliance checks passed"
    return 0
}

# =====================================================
# WORK-SPECIFIC PROMPT ADDITIONS
# =====================================================

# Show VPN status in prompt (if applicable)
vpn_status_prompt() {
    if pgrep -x "openconnect" > /dev/null; then
        echo " VPN"
    fi
}

# =====================================================
# COMPANY-SPECIFIC TOOL INTEGRATIONS
# =====================================================

# Example: Company CLI tool
{{- if ne .secrets.work.write_token "" }}
export WRITE_TOKEN="{{ .secrets.work.write_token }}"
{{- end }}

{{- if ne .secrets.work.gl_token "" }}
export GL_TOKEN="{{ .secrets.work.gl_token }}"
{{- end }}

# =====================================================
# WORK TIME TRACKING
# =====================================================

# Log work session start
work_start() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$timestamp - Started work session" >> "$HOME/work/.work_log"
    echo "🏢 Work session started at $(date "+%H:%M")"
}

# Log work session end
work_end() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$timestamp - Ended work session" >> "$HOME/work/.work_log"
    echo "👋 Work session ended at $(date "+%H:%M")"
}

# Show today's work log
work_today() {
    local today=$(date "+%Y-%m-%d")
    grep "$today" "$HOME/work/.work_log" 2>/dev/null || echo "No work logged today"
}
