#!/bin/bash
# Cross-platform OS detection utility for tmux scripts
# Returns: macos, linux, or unknown

detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

# Export for sourcing
export -f detect_os

# If called directly, just return the OS
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    detect_os
fi