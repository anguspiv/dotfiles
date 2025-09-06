# Chezmoi helper functions

# Check if there are pending chezmoi changes
chezmoi_status_check() {
    if command -v chezmoi >/dev/null 2>&1; then
        local status=$(chezmoi status 2>/dev/null)
        if [[ -n "$status" ]]; then
            echo "📝"  # Indicator that changes are pending
        fi
    fi
}

# Show detailed chezmoi status
chezmoi_show_status() {
    if ! command -v chezmoi >/dev/null 2>&1; then
        echo "chezmoi not installed"
        return 1
    fi
    
    local status=$(chezmoi status 2>/dev/null)
    if [[ -n "$status" ]]; then
        echo "📝 Chezmoi changes detected:"
        echo "$status"
        echo ""
        echo "💡 Run 'cmsync' to automatically sync changes"
    else
        echo "✅ All dotfiles are up to date"
    fi
}

# Quick sync function with confirmation
chezmoi_quick_sync() {
    echo "🔍 Checking for changes..."
    local status=$(chezmoi status 2>/dev/null)
    
    if [[ -z "$status" ]]; then
        echo "✅ No changes detected"
        return 0
    fi
    
    echo "📝 Changes found:"
    echo "$status"
    echo ""
    
    if [[ "${1:-}" == "--force" ]] || [[ "${1:-}" == "-f" ]]; then
        chezmoi-sync
    else
        read -p "🚀 Sync these changes? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            chezmoi-sync
        else
            echo "❌ Sync cancelled"
        fi
    fi
}

# Auto-run chezmoi status check on directory change (optional)
# Uncomment the next lines to enable automatic status checks
# chpwd() {
#     chezmoi_status_check
# }