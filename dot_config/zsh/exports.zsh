# Environment Variables and Exports

# Editor configuration
if [[ -z "${EDITOR}" ]]; then
    export EDITOR=nvim
fi
export VISUAL="$EDITOR"

# GPG configuration
export GPG_TTY=$(tty)

# PATH management - using typeset -U to keep unique entries
typeset -U path
path=(
    $HOME/.bin
    /usr/local/sbin
    $path
)

# Node/PNPM configuration
export PNPM_HOME="/Users/angusp/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac