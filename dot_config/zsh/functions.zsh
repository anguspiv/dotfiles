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

# Setup true lazy loading for performance-heavy tools
setup_lazy_loading() {
    # Cache command existence to avoid repeated checks
    local has_fnm has_zoxide has_starship has_fzf
    has_fnm=$(command -v fnm >/dev/null 2>&1 && echo 1 || echo 0)
    has_zoxide=$(command -v zoxide >/dev/null 2>&1 && echo 1 || echo 0)
    has_starship=$(command -v starship >/dev/null 2>&1 && echo 1 || echo 0)
    has_fzf=$([[ -f ~/.fzf.zsh ]] || command -v fzf >/dev/null 2>&1 && echo 1 || echo 0)

    # Initialize fnm immediately for proper Node version management
    if [[ $has_fnm -eq 1 ]]; then
        eval "$(fnm env --use-on-cd --shell zsh)"
        eval "$(fnm completions --shell zsh)"
    fi

    # Initialize zoxide immediately for cd replacement
    if [[ $has_zoxide -eq 1 ]]; then
        eval "$(zoxide init zsh)"
    fi

    # Starship prompt - initialize immediately (needed for prompt display)
    # This is the exception - prompts need to be ready immediately
    if [[ $has_starship -eq 1 ]]; then
        eval "$(starship init zsh)"
    fi

    # True lazy loading for fzf
    if [[ $has_fzf -eq 1 ]]; then
        _fzf_initialize() {
            unfunction _fzf_initialize
            if [[ -f ~/.fzf.zsh ]]; then
                source ~/.fzf.zsh
            else
                source <(fzf --zsh)
            fi
        }
        # Create lazy wrapper for common fzf functions
        fzf() { _fzf_initialize; fzf "$@"; }
        # Add other common fzf functions as needed
        __fzf_history__() { _fzf_initialize; __fzf_history__ "$@"; }
        __fzf_cd__() { _fzf_initialize; __fzf_cd__ "$@"; }
    fi
}