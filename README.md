# Dotfiles with Chezmoi

Personal dotfiles managed with [chezmoi](https://chezmoi.io), providing a consistent development environment across macOS, Linux, and SteamOS machines.

## Features

- **Cross-platform support**: macOS, Linux, SteamOS
- **Machine-specific configurations**: Different setups for personal, work, and server machines
- **Performance optimization**: Configurations adapt to machine performance levels
- **Feature flags**: Modular enablement of tools (AI, development, Kubernetes)
- **Automated setup**: One-command installation for new machines
- **Template-based**: Dynamic configuration based on machine type and preferences

## Quick Start

### New Machine Setup

1. **Install chezmoi**:
   ```bash
   # macOS (Homebrew)
   brew install chezmoi
   
   # Linux (most distributions)
   sh -c "$(curl -fsLS get.chezmoi.io)"
   
   # Or download from https://github.com/twpayne/chezmoi/releases
   ```

2. **Initialize dotfiles**:
   ```bash
   chezmoi init https://github.com/angusp/dotfiles.git
   ```

3. **Configure your machine** (interactive prompts):
   ```bash
   chezmoi init
   ```

   You'll be prompted for:
   - Full name and email
   - Machine type (development, server, minimal, steamos)
   - Performance level (high, medium, low, handheld)
   - Feature flags (AI tools, development tools, git tools, kubernetes)

4. **Review changes**:
   ```bash
   chezmoi diff
   ```

5. **Apply dotfiles**:
   ```bash
   chezmoi apply
   ```

### Existing Machine Update

```bash
# Pull latest changes from repository
chezmoi update

# Or manually:
chezmoi git pull
chezmoi apply
```

## Machine Types

| Type | Description | Use Case |
|------|-------------|----------|
| `development` | Full development environment | Primary development machine |
| `server` | Minimal server configuration | Remote servers, VPS |
| `minimal` | Basic shell configuration | Shared/restricted machines |
| `steamos` | Steam Deck optimized | Handheld gaming device |

## Performance Levels

| Level | Description | Optimizations |
|-------|-------------|---------------|
| `high` | High-performance machine | All features, caching enabled |
| `medium` | Standard performance | Balanced configuration |
| `low` | Resource-constrained | Minimal features, faster loading |
| `handheld` | Battery-conscious | Reduced CPU usage, simplified UI |

## Feature Flags

- **AI Tools** (`ai_tools`): Claude, Anthropic integration, AI-powered development tools
- **Development Tools** (`development_tools`): Full development stack, languages, frameworks
- **Git Tools** (`git_tools`): Advanced git configuration, hooks, and utilities
- **Kubernetes** (`kubernetes`): kubectl, k9s, and container orchestration tools

## Directory Structure

```
~/.local/share/chezmoi/
├── README.md                              # This file
├── .chezmoi.yaml.tmpl                     # Configuration template
├── .chezmoiignore                         # Files to ignore
├── dot_zshrc.tmpl                         # Zsh configuration
├── dot_gitconfig.tmpl                     # Git configuration
├── dot_tmux.conf                          # Tmux configuration
├── dot_config/
│   ├── nvim/                              # Neovim configuration
│   ├── Code/User/                         # VS Code settings
│   ├── steamos/                           # Steam Deck specific
│   └── zsh/                               # Zsh modules
├── run_once_*.sh.tmpl                     # One-time setup scripts
├── run_onchange_*.sh.tmpl                 # Update scripts
└── Documents/                             # Document templates
```

## Common Workflows

### Adding New Dotfiles

1. **Add a file to chezmoi**:
   ```bash
   chezmoi add ~/.vimrc
   ```

2. **Edit managed files**:
   ```bash
   chezmoi edit ~/.zshrc
   ```

3. **Commit changes**:
   ```bash
   chezmoi cd
   git add .
   git commit -m "Add vim configuration"
   git push
   ```

### Managing Templates

1. **Convert file to template**:
   ```bash
   # Rename file to add .tmpl extension
   chezmoi cd
   mv dot_vimrc dot_vimrc.tmpl
   ```

2. **Use template variables**:
   ```bash
   # In template files, use variables like:
   # {{ .name }} - Your name
   # {{ .email }} - Your email
   # {{ .machine.type }} - Machine type
   # {{ .features.ai_tools }} - Feature flags
   ```

3. **Test templates**:
   ```bash
   chezmoi execute-template < ~/.local/share/chezmoi/dot_vimrc.tmpl
   ```

### Machine-Specific Configurations

1. **Create machine-specific files**:
   ```bash
   # Only applied on SteamOS machines
   dot_config/steamos/README.md.tmpl
   
   # Conditional content within templates
   {{- if eq .machine.type "steamos" -}}
   # SteamOS specific configuration
   {{- end -}}
   ```

2. **Performance-based configurations**:
   ```bash
   {{- if eq .machine.performance "high" -}}
   # Resource-intensive settings
   {{- else -}}
   # Resource-conscious settings
   {{- end -}}
   ```

### Secret Management

1. **Ignore sensitive files**:
   ```bash
   echo ".ssh/id_*" >> ~/.local/share/chezmoi/.chezmoiignore
   ```

2. **Use external secret managers**:
   ```bash
   # Example with 1Password
   chezmoi secret onepassword --account="your-account"
   ```

### Updating Configuration

1. **Reconfigure machine**:
   ```bash
   # Re-run configuration prompts
   chezmoi init --promptOnce=false
   ```

2. **Update specific settings**:
   ```bash
   # Edit configuration directly
   chezmoi edit-config
   ```

3. **Force regenerate templates**:
   ```bash
   chezmoi apply --force
   ```

## Platform-Specific Notes

### macOS
- Homebrew packages automatically installed via `Brewfile`
- macOS-specific configurations in templates
- Includes GUI applications and fonts

### Linux
- Package installation via distribution package managers
- Systemd service configurations
- Desktop environment specific settings

### SteamOS (Steam Deck)
- Optimized for handheld constraints
- Touch-friendly configurations
- Battery-conscious settings
- Flatpak application management

## Troubleshooting

### Common Issues

1. **Template execution errors**:
   ```bash
   # Check template syntax
   chezmoi execute-template < problematic-file.tmpl
   
   # Verify data availability
   chezmoi data
   ```

2. **Configuration not found**:
   ```bash
   # Reinitialize if config is missing
   chezmoi init
   ```

3. **Permission errors**:
   ```bash
   # Fix file permissions
   chezmoi apply --force
   ```

4. **Git authentication issues**:
   ```bash
   # Re-authenticate with git
   chezmoi cd
   git remote set-url origin https://github.com/angusp/dotfiles.git
   ```

### Debugging

1. **Verbose output**:
   ```bash
   chezmoi apply --verbose
   ```

2. **Dry run changes**:
   ```bash
   chezmoi apply --dry-run
   ```

3. **Check differences**:
   ```bash
   chezmoi diff
   ```

4. **Verify configuration**:
   ```bash
   chezmoi doctor
   ```

## Development

### Local Testing

1. **Test on different machine types**:
   ```bash
   # Temporarily change machine type
   chezmoi execute-template --init '{{ .machine.type = "steamos" }}' < template.tmpl
   ```

2. **Validate templates**:
   ```bash
   # Check all templates compile
   find ~/.local/share/chezmoi -name "*.tmpl" -exec chezmoi execute-template {} \;
   ```

### Contributing

1. **Fork and clone** the repository
2. **Make changes** in feature branches
3. **Test thoroughly** on different platforms
4. **Submit pull request** with description

## Advanced Configuration

### Custom Scripts

- `run_once_*.sh.tmpl`: Scripts that run once during initial setup
- `run_onchange_*.sh.tmpl`: Scripts that run when templates change
- `run_after_*.sh.tmpl`: Scripts that run after applying dotfiles

### External Data

```yaml
# .chezmoi.yaml.tmpl can include external data
data:
  github:
    username: "{{ output "gh" "api" "user" "--jq" ".login" | trim }}"
```

### Hooks

Configure git hooks for automatic synchronization:

```bash
# In chezmoi source directory
echo '#!/bin/bash\nchezmoi apply' > .git/hooks/post-merge
chmod +x .git/hooks/post-merge
```

## Support

- **Documentation**: [chezmoi.io](https://chezmoi.io)
- **Issues**: [GitHub Issues](https://github.com/angusp/dotfiles/issues)
- **Discussions**: [GitHub Discussions](https://github.com/twpayne/chezmoi/discussions)

## License

This configuration is released under the MIT License. See LICENSE file for details.

---

*Last updated: January 2025*