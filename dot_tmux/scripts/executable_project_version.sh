#!/usr/bin/env bash
# Smart project type and version detector
# Detects language/runtime based on project files and shows appropriate version

CACHE_FILE="/tmp/tmux_project_version_$$"
CACHE_TTL=60  # Cache for 60 seconds

# Check cache
if [[ -f "$CACHE_FILE" ]]; then
    CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [[ $CACHE_AGE -lt $CACHE_TTL ]]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Get current directory (passed as argument or use pwd)
PROJECT_DIR="${1:-$(pwd)}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

OUTPUT=""

# Python Projects (check for conda first, then venv, then python)
check_python() {
    # Check for conda environment
    if [[ -n "$CONDA_DEFAULT_ENV" ]] && [[ "$CONDA_DEFAULT_ENV" != "base" ]]; then
        local python_version=$(python --version 2>&1 | awk '{print $2}' | cut -d. -f1-2)
        OUTPUT=" py${python_version}"
        return 0
    fi

    # Check for virtual environment
    if [[ -n "$VIRTUAL_ENV" ]] || [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "requirements.txt" ]] || [[ -f "Pipfile" ]] || [[ -f "poetry.lock" ]]; then
        if command -v python3 >/dev/null 2>&1; then
            local python_version=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1-2)
            OUTPUT=" py${python_version}"
            return 0
        elif command -v python >/dev/null 2>&1; then
            local python_version=$(python --version 2>&1 | awk '{print $2}' | cut -d. -f1-2)
            OUTPUT=" py${python_version}"
            return 0
        fi
    fi
    return 1
}

# Node.js/JavaScript Projects
check_node() {
    if [[ -f "package.json" ]] || [[ -f "yarn.lock" ]] || [[ -f "pnpm-lock.yaml" ]] || [[ -f "bun.lockb" ]]; then
        if command -v node >/dev/null 2>&1; then
            local node_version=$(node -v 2>/dev/null | cut -c2- | cut -d. -f1)
            OUTPUT=" v${node_version}"
            return 0
        fi
    fi
    return 1
}

# Rust Projects
check_rust() {
    if [[ -f "Cargo.toml" ]] || [[ -f "Cargo.lock" ]]; then
        if command -v rustc >/dev/null 2>&1; then
            local rust_version=$(rustc --version 2>/dev/null | awk '{print $2}' | cut -d. -f1-2)
            OUTPUT=" ${rust_version}"
            return 0
        fi
    fi
    return 1
}

# Go Projects
check_go() {
    if [[ -f "go.mod" ]] || [[ -f "go.sum" ]]; then
        if command -v go >/dev/null 2>&1; then
            local go_version=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
            OUTPUT=" ${go_version}"
            return 0
        fi
    fi
    return 1
}

# Java Projects
check_java() {
    if [[ -f "pom.xml" ]] || [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]] || [[ -f "gradlew" ]]; then
        if command -v java >/dev/null 2>&1; then
            local java_version=$(java -version 2>&1 | head -1 | awk -F'"' '{print $2}' | cut -d. -f1)
            OUTPUT=" ${java_version}"
            return 0
        fi
    fi
    return 1
}

# Ruby Projects
check_ruby() {
    if [[ -f "Gemfile" ]] || [[ -f "Gemfile.lock" ]] || [[ -f ".ruby-version" ]]; then
        if command -v ruby >/dev/null 2>&1; then
            local ruby_version=$(ruby -v 2>/dev/null | awk '{print $2}' | cut -d. -f1-2)
            OUTPUT=" ${ruby_version}"
            return 0
        fi
    fi
    return 1
}

# PHP Projects
check_php() {
    if [[ -f "composer.json" ]] || [[ -f "composer.lock" ]]; then
        if command -v php >/dev/null 2>&1; then
            local php_version=$(php -v 2>/dev/null | head -1 | awk '{print $2}' | cut -d. -f1-2)
            OUTPUT=" ${php_version}"
            return 0
        fi
    fi
    return 1
}

# Elixir Projects
check_elixir() {
    if [[ -f "mix.exs" ]]; then
        if command -v elixir >/dev/null 2>&1; then
            local elixir_version=$(elixir --version 2>/dev/null | grep "Elixir" | awk '{print $2}')
            OUTPUT=" ${elixir_version}"
            return 0
        fi
    fi
    return 1
}

# C/C++ Projects
check_cpp() {
    if [[ -f "CMakeLists.txt" ]] || [[ -f "Makefile" ]] || [[ -f "meson.build" ]]; then
        # Just show C/C++ icon without version (compiler versions are complex)
        OUTPUT=""
        return 0
    fi
    return 1
}

# Zig Projects
check_zig() {
    if [[ -f "build.zig" ]]; then
        if command -v zig >/dev/null 2>&1; then
            local zig_version=$(zig version 2>/dev/null)
            OUTPUT=" ${zig_version}"
            return 0
        fi
    fi
    return 1
}

# Terraform Projects
check_terraform() {
    if ls *.tf >/dev/null 2>&1 || [[ -d ".terraform" ]]; then
        if command -v terraform >/dev/null 2>&1; then
            local tf_version=$(terraform version -json 2>/dev/null | grep -o '"terraform_version":"[^"]*"' | cut -d'"' -f4)
            if [[ -z "$tf_version" ]]; then
                tf_version=$(terraform version 2>/dev/null | head -1 | awk '{print $2}' | sed 's/v//')
            fi
            OUTPUT="󱁢 ${tf_version}"
            return 0
        fi
    fi
    return 1
}

# Docker Projects
check_docker() {
    if [[ -f "Dockerfile" ]] || [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]]; then
        OUTPUT=""
        return 0
    fi
    return 1
}

# Priority order: check more specific project types first
check_python || \
check_rust || \
check_go || \
check_node || \
check_java || \
check_ruby || \
check_php || \
check_elixir || \
check_zig || \
check_terraform || \
check_cpp || \
check_docker

# If nothing detected, try to show default node if available
if [[ -z "$OUTPUT" ]] && command -v node >/dev/null 2>&1; then
    node_version=$(node -v 2>/dev/null | cut -c2- | cut -d. -f1)
    OUTPUT=" v${node_version}"
fi

# Cache and output result
echo "$OUTPUT" > "$CACHE_FILE"
echo "$OUTPUT"
