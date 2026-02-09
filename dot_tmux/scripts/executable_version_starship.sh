#!/usr/bin/env bash
# Starship-style version indicator with clear icons

CACHE_FILE="/tmp/tmux_version_$$"
CACHE_TTL=60

if [[ -f "$CACHE_FILE" ]]; then
    CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [[ $CACHE_AGE -lt $CACHE_TTL ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

PROJECT_DIR="${1:-$(pwd)}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

OUTPUT=""

check_python() {
    if [[ -n "$CONDA_DEFAULT_ENV" ]] || [[ -n "$VIRTUAL_ENV" ]] || [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
        if command -v python3 >/dev/null 2>&1; then
            local version=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1-2)
            OUTPUT="  ${version}"
            return 0
        fi
    fi
    return 1
}

check_node() {
    if [[ -f "package.json" ]]; then
        if command -v node >/dev/null 2>&1; then
            local version=$(node -v 2>/dev/null)
            OUTPUT="  ${version}"
            return 0
        fi
    fi
    return 1
}

check_rust() {
    if [[ -f "Cargo.toml" ]]; then
        if command -v rustc >/dev/null 2>&1; then
            local version=$(rustc --version 2>/dev/null | awk '{print $2}')
            OUTPUT="  ${version}"
            return 0
        fi
    fi
    return 1
}

check_go() {
    if [[ -f "go.mod" ]]; then
        if command -v go >/dev/null 2>&1; then
            local version=$(go version 2>/dev/null | awk '{print $3}')
            OUTPUT="  ${version}"
            return 0
        fi
    fi
    return 1
}

check_python || check_rust || check_go || check_node

echo "$OUTPUT" > "$CACHE_FILE"
echo "$OUTPUT"
