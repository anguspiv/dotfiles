# Shell Functions

# Utility function to source files if they exist
source_if_exists() {
	if [[ -f $1 ]]; then
		source $1
	fi
}

# Lazy loading function for heavy tools
lazy_load_tool() {
    local tool_name="$1"
    local init_command="$2"
    
    # Create a wrapper function that initializes the tool on first use
    eval "${tool_name}() {
        unfunction ${tool_name}
        eval \"${init_command}\"
        ${tool_name} \"\$@\"
    }"
}

# Setup lazy loading for performance-heavy tools
setup_lazy_loading() {
    # Lazy load fnm (Node version manager)
    if command -v fnm >/dev/null 2>&1; then
        lazy_load_tool "fnm" 'eval "$(fnm env --use-on-cd --shell zsh)" && eval "$(fnm completions --shell zsh)"'
    fi
    
    # Initialize zoxide immediately (lightweight and commonly used)
    if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init zsh)"
    fi
    
    # Lazy load starship prompt (keep this immediate for visual feedback)
    if command -v starship >/dev/null 2>&1; then
        eval "$(starship init zsh)"
    fi
    
    # Load fzf immediately as it's lightweight and commonly used
    if [[ -f ~/.fzf.zsh ]]; then
        source ~/.fzf.zsh
    elif command -v fzf >/dev/null 2>&1; then
        source <(fzf --zsh)
    fi
}