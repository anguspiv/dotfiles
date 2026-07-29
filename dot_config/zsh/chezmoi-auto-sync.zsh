# Chezmoi Auto-Sync Configuration
# Multiple strategies for keeping dotfiles synchronized

# =====================================================
# CONFIGURATION
# =====================================================

# How often to check for changes (in seconds)
CHEZMOI_CHECK_INTERVAL=${CHEZMOI_CHECK_INTERVAL:-3600}  # Default: 1 hour

# Auto-sync mode (choose one):
# - "notify" : Just notify about changes (default, safest)
# - "prompt" : Prompt to sync when changes detected
# - "auto"   : Automatically sync (requires git to be clean)
CHEZMOI_SYNC_MODE=${CHEZMOI_SYNC_MODE:-notify}

# Show reminders on shell startup (disabled for tmux - prevents spam on new panes)
CHEZMOI_STARTUP_CHECK=${CHEZMOI_STARTUP_CHECK:-false}

# File to track last check time
CHEZMOI_LAST_CHECK_FILE="${HOME}/.cache/chezmoi_last_check"

# =====================================================
# HELPER FUNCTIONS
# =====================================================

# Check if chezmoi is installed
_chezmoi_installed() {
    command -v chezmoi >/dev/null 2>&1
}

# Get time since last check (in seconds)
_chezmoi_time_since_check() {
    if [[ ! -f "$CHEZMOI_LAST_CHECK_FILE" ]]; then
        echo "999999"  # Force check
        return
    fi

    local last_check=$(cat "$CHEZMOI_LAST_CHECK_FILE")
    local now=$(date +%s)
    echo $((now - last_check))
}

# Update last check timestamp
_chezmoi_update_check_time() {
    mkdir -p "$(dirname "$CHEZMOI_LAST_CHECK_FILE")"
    date +%s > "$CHEZMOI_LAST_CHECK_FILE"
}

# Check if there are local changes
_chezmoi_has_local_changes() {
    local chezmoi_status=$(chezmoi status 2>/dev/null)
    [[ -n "$chezmoi_status" ]]
}

# Check if remote has updates
_chezmoi_has_remote_updates() {
    chezmoi cd 2>/dev/null || return 1
    git fetch --quiet 2>/dev/null || return 1

    local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)
    cd - >/dev/null

    [[ "$behind" -gt 0 ]]
}

# =====================================================
# NOTIFICATION FUNCTIONS
# =====================================================

_chezmoi_notify() {
    local title="$1"
    local message="$2"

    # Terminal notification — skip when running from the background periodic
    # check, where printing would corrupt the active prompt/formatting.
    if [[ "$_CHEZMOI_BACKGROUND" != true ]]; then
        echo "📦 $title: $message"
    fi

    # macOS notification (if available)
    if command -v osascript >/dev/null 2>&1; then
        osascript -e "display notification \"$message\" with title \"Chezmoi\" subtitle \"$title\"" 2>/dev/null
    fi

    # Linux notification (if available)
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Chezmoi: $title" "$message" 2>/dev/null
    fi
}

# =====================================================
# SYNC FUNCTIONS
# =====================================================

# Pull updates from remote
chezmoi_pull() {
    echo "🔄 Pulling chezmoi updates..."

    if chezmoi git pull 2>/dev/null; then
        echo "📥 Changes pulled from remote"

        # Show what changed
        local changes=$(chezmoi diff --no-pager 2>/dev/null | head -20)
        if [[ -n "$changes" ]]; then
            echo "\n📝 Changes detected:"
            echo "$changes"
            echo "\n💡 Run 'chezmoi apply' to apply changes"
        else
            echo "✅ Already up to date"
        fi
    else
        echo "❌ Failed to pull updates"
        return 1
    fi
}

# Push local changes to remote
chezmoi_push() {
    echo "🚀 Pushing chezmoi changes..."

    # Check for uncommitted changes
    if _chezmoi_has_local_changes; then
        echo "📝 Uncommitted local changes detected"
        chezmoi status
        return 1
    fi

    chezmoi cd 2>/dev/null || return 1

    # Check if we have commits to push
    local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
    if [[ "$ahead" -gt 0 ]]; then
        if git push; then
            echo "✅ Pushed $ahead commit(s) to remote"
        else
            echo "❌ Failed to push"
            cd - >/dev/null
            return 1
        fi
    else
        echo "✅ Already up to date with remote"
    fi

    cd - >/dev/null
}

# Full sync: pull, apply, commit, push
chezmoi_full_sync() {
    echo "🔄 Starting full chezmoi sync..."

    # Pull updates
    if _chezmoi_has_remote_updates; then
        chezmoi_pull || return 1

        # Prompt to apply
        if [[ -n "$(chezmoi diff 2>/dev/null)" ]]; then
            read -k 1 "REPLY?Apply changes? (y/N): "
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                chezmoi apply
            fi
        fi
    fi

    # Commit local changes if any
    if _chezmoi_has_local_changes; then
        echo "\n📝 Local changes detected:"
        chezmoi status

        read -k 1 "REPLY?Commit and push changes? (y/N): "
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            chezmoi cd

            read "commit_msg?Commit message: "
            if [[ -n "$commit_msg" ]]; then
                git add .
                git commit -m "$commit_msg"
                git push
                echo "✅ Changes committed and pushed"
            fi

            cd - >/dev/null
        fi
    fi

    echo "✅ Sync complete"
}

# =====================================================
# AUTO-CHECK FUNCTIONS
# =====================================================

# Main check function
_chezmoi_auto_check() {
    # Skip if chezmoi not installed
    _chezmoi_installed || return 0

    # Check if it's time for a check
    local time_since_check=$(_chezmoi_time_since_check)
    if [[ "$time_since_check" -lt "$CHEZMOI_CHECK_INTERVAL" ]]; then
        return 0
    fi

    # Update check time
    _chezmoi_update_check_time

    # Check for changes
    local has_local=false
    local has_remote=false

    if _chezmoi_has_local_changes; then
        has_local=true
    fi

    if _chezmoi_has_remote_updates; then
        has_remote=true
    fi

    # Handle based on mode
    case "$CHEZMOI_SYNC_MODE" in
        notify)
            if [[ "$has_local" == true ]]; then
                _chezmoi_notify "Local Changes" "You have uncommitted dotfile changes. Run 'cmsync' to sync."
            fi
            if [[ "$has_remote" == true ]]; then
                _chezmoi_notify "Remote Updates" "New dotfile updates available. Run 'chezmoi update' to pull."
            fi
            ;;

        prompt)
            if [[ "$has_remote" == true ]]; then
                echo "\n📦 Chezmoi: Remote updates available"
                read -k 1 "REPLY?Pull updates now? (y/N): "
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    chezmoi_pull
                fi
            fi

            if [[ "$has_local" == true ]]; then
                echo "\n📦 Chezmoi: Local changes detected"
                read -k 1 "REPLY?Sync changes now? (y/N): "
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    chezmoi_full_sync
                fi
            fi
            ;;

        auto)
            if [[ "$has_remote" == true ]]; then
                echo "🔄 Auto-pulling chezmoi updates..."
                chezmoi update
            fi

            # Auto-push only if git is clean
            if [[ "$has_local" == true ]]; then
                echo "⚠️  Local changes detected but not auto-pushing (use 'prompt' or 'notify' mode for safety)"
            fi
            ;;
    esac
}

# Startup check (lightweight)
_chezmoi_startup_check() {
    # Skip if disabled
    [[ "$CHEZMOI_STARTUP_CHECK" != true ]] && return 0

    # Skip if chezmoi not installed
    _chezmoi_installed || return 0

    # Quick check for local changes only (no network)
    if _chezmoi_has_local_changes; then
        echo "📝 Chezmoi: You have uncommitted changes. Run 'cms' to see them."
    fi
}

# =====================================================
# PERIODIC CHECK (Background)
# =====================================================

# Start periodic checking in background
_chezmoi_start_periodic_check() {
    # Only run in interactive shells
    [[ -o interactive ]] || return 0

    # Only run when stdout is a real terminal. Tools that capture the shell
    # environment (Zed's `zed --printenv`, Claude Code's env probes) invoke
    # `zsh -l -i -c '... env'` with stdout on a pipe; a long-lived background
    # child there holds the write end open and the caller hangs forever waiting
    # for EOF.
    [[ -t 1 ]] || return 0

    # Don't run if already running. Verify the PID is actually alive: a stale
    # exported value inherited from a parent shell would otherwise permanently
    # disable the check in every child.
    [[ -n "$CHEZMOI_CHECK_PID" ]] && kill -0 "$CHEZMOI_CHECK_PID" 2>/dev/null && return 0

    # The background job cannot interactively prompt, and printing to the
    # terminal would corrupt the active prompt. Force notify mode (native
    # macOS/Linux notifications only) regardless of the configured mode.
    # stdio goes to /dev/null so this child can never hold a caller's
    # descriptors open (belt-and-braces with the -t 1 guard above).
    (
        while true; do
            sleep "$CHEZMOI_CHECK_INTERVAL"
            CHEZMOI_SYNC_MODE=notify _CHEZMOI_BACKGROUND=true _chezmoi_auto_check
        done
    ) </dev/null >/dev/null 2>&1 &

    export CHEZMOI_CHECK_PID=$!
    disown  # Disown the most recent background job (prevent "you have running jobs" warning)
}

# Stop periodic checking (cleanup)
_chezmoi_stop_periodic_check() {
    if [[ -n "$CHEZMOI_CHECK_PID" ]]; then
        kill $CHEZMOI_CHECK_PID 2>/dev/null
        unset CHEZMOI_CHECK_PID
    fi
}

# Set up cleanup on shell exit
_chezmoi_setup_exit_hook() {
    # Use ZSHEXIT hook to clean up background process
    function _chezmoi_exit_handler() {
        _chezmoi_stop_periodic_check
    }

    # Add to zshexit hook array
    zshexit_functions+=(_chezmoi_exit_handler)
}

# =====================================================
# INTEGRATION FUNCTIONS
# =====================================================

# Check on directory change (optional)
_chezmoi_chpwd_check() {
    # Only check if we're in home directory or chezmoi directory
    if [[ "$PWD" == "$HOME" ]] || [[ "$PWD" == "$HOME/.local/share/chezmoi"* ]]; then
        _chezmoi_auto_check
    fi
}

# =====================================================
# ALIASES & SHORTCUTS
# =====================================================

alias cmpull="chezmoi_pull"
alias cmpush="chezmoi_push"
alias cmsync="chezmoi_full_sync"
alias cmcheck="_chezmoi_auto_check"

# =====================================================
# INITIALIZATION
# =====================================================

# Set up exit hook for cleanup
_chezmoi_setup_exit_hook

# Only run startup check in first shell of tmux session (or non-tmux shells)
if [[ -z "$TMUX" ]] || [[ "$TMUX_PANE" == "%0" ]]; then
    _chezmoi_startup_check
fi

# Start periodic checking (if enabled)
# Uncomment to enable background checking:
# _chezmoi_start_periodic_check

# Hook into directory changes (optional)
# Uncomment to check when changing directories:
# autoload -U add-zsh-hook
# add-zsh-hook chpwd _chezmoi_chpwd_check
