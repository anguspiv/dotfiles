# Multi-Machine Configuration Guide

Complete guide for managing dotfiles across work and personal machines using chezmoi.

## 📋 Table of Contents

- [Overview](#overview)
- [Machine Contexts](#machine-contexts)
- [Initial Setup](#initial-setup)
- [Syncing Between Machines](#syncing-between-machines)
- [Work vs Personal](#work-vs-personal)
- [Secret Management](#secret-management)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This configuration is optimized for managing two main types of machines:
- **Work Machine**: Company laptop with work-specific tools and configurations
- **Personal Machine**: Home computer for personal projects and learning

### Key Features

✅ Context-aware configurations (work/personal)
✅ Separate secret management per context
✅ Machine-specific feature flags
✅ Performance-optimized settings
✅ Tmux session templates per context
✅ Git configuration switching
✅ Claude Code integration

## 🖥️ Machine Contexts

### Work Machine
**Characteristics:**
- Email: `@disney.com` domain
- VPN access
- Company tools integration
- Kubernetes/Docker for services
- Professional git signing

**Enabled Features:**
- Development tools
- Git tools with signing
- Kubernetes tools
- Docker tools
- AI tools (with work restrictions)

**Tmux Sessions:**
- `work-main`: Editor, terminal, git
- `services`: Backend, frontend, logs
- `work-logs`: Application and Docker logs

### Personal Machine
**Characteristics:**
- Personal email
- Open-source projects
- Learning environment
- Experimental tools
- Personal API keys

**Enabled Features:**
- Full AI tools access
- Development tools
- Personal project management
- Learning resources

**Tmux Sessions:**
- `dev`: Development workflow
- `project`: Project-specific sessions
- `learning`: Notes and terminal

## 🚀 Initial Setup

### Step 1: Install Chezmoi

```bash
# macOS
brew install chezmoi

# Linux
sh -c "$(curl -fsLS get.chezmoi.io)"
```

### Step 2: Initialize Your Dotfiles

#### For Work Machine

```bash
# Initialize chezmoi
chezmoi init https://github.com/yourusername/dotfiles.git

# You'll be prompted:
# - Full name: Angus Perkerson
# - Email: angus.perkerson@disney.com
# - Machine context: work  ← Select "work"
# - Machine type: development
# - Performance: high
# - Enable AI tools: yes
# - Enable development tools: yes
# - Enable git tools: yes
# - Enable kubernetes: yes
# - Enable docker: yes
# - Tmux session management: yes

# Enter work-specific secrets:
# - WRITE_TOKEN: [your token]
# - GitLab token: [your token]
# - JIRA token: [your token]
# - Figma token: [your token]
# - Confluence settings: [as prompted]
```

#### For Personal Machine

```bash
# Initialize chezmoi
chezmoi init https://github.com/yourusername/dotfiles.git

# You'll be prompted:
# - Full name: Angus Perkerson
# - Email: your.personal@email.com
# - Machine context: personal  ← Select "personal"
# - Machine type: development
# - Performance: high (or medium)
# - Enable AI tools: yes
# - Enable development tools: yes
# - Tmux session management: yes

# Enter personal secrets:
# - GitHub token: [your PAT]
# - Anthropic API key: [your key]
# - OpenAI API key: [your key]
```

### Step 3: Review and Apply

```bash
# Review what will change
chezmoi diff

# Apply the configuration
chezmoi apply

# Restart your shell
exec zsh
```

## 🔄 Syncing Between Machines

### Quick Sync Workflow

```bash
# On any machine - pull latest changes
chezmoi update

# Or manually:
chezmoi git pull
chezmoi apply
```

### Making Changes

#### 1. Edit Configuration

```bash
# Edit a file
chezmoi edit ~/.zshrc

# Or edit the source directly
chezmoi cd
nvim dot_zshrc.tmpl
```

#### 2. Test Changes

```bash
# See what would change
chezmoi diff

# Apply to test
chezmoi apply
```

#### 3. Commit and Push

```bash
# Enter chezmoi directory
chezmoi cd

# Check status
git status

# Commit changes
git add .
git commit -m "Update zsh configuration for better performance"
git push

# Return to normal directory
exit
```

#### 4. Pull on Other Machine

```bash
# On your other machine
chezmoi update

# Or step by step:
chezmoi git pull
chezmoi diff  # Review changes
chezmoi apply
```

### Automated Sync

Add to your `~/.config/zsh/chezmoi-functions.zsh`:

```bash
# Auto-sync on shell start (optional)
chezmoi_auto_sync() {
    if [[ -n "$(chezmoi status 2>/dev/null)" ]]; then
        echo "📝 Chezmoi changes detected"
        echo "Run 'cmsync' to synchronize"
    fi
}

# Uncomment to enable auto-check
# chezmoi_auto_sync
```

## ⚖️ Work vs Personal

### Context Detection

Your configuration automatically detects the machine context:

```bash
# Check current context
echo $MACHINE_CONTEXT
# Output: "work" or "personal"

# In your shell scripts
if [[ "$MACHINE_CONTEXT" == "work" ]]; then
    # Work-specific logic
fi
```

### Context-Specific Files

Files are loaded based on context:

**Work Machine:**
- `~/.config/zsh/work.zsh` ← Work-specific aliases and functions
- `~/.tmux.work.conf` ← Work tmux configuration
- Git uses: `angus.perkerson@disney.com`

**Personal Machine:**
- `~/.config/zsh/personal.zsh` ← Personal aliases and functions
- `~/.tmux.personal.conf` ← Personal tmux configuration
- Git uses: Your personal email

### Switching Git Context

If you need to temporarily switch:

```bash
# On work machine, use personal email for a repo
personal_git_config

# On personal machine, use work email
work_git_config  # (if you have work email configured)
```

### Tmux Sessions

**Work Machine:**
```bash
# Start work sessions
tmux-work-session main      # or: <prefix> + W
tmux-work-session services  # or: <prefix> + S
tmux-work-session logs      # or: <prefix> + L

# Or use aliases
tmwork
tmlogs
tmservices
```

**Personal Machine:**
```bash
# Start personal sessions
tmux-personal-session dev       # or: <prefix> + D
tmux-personal-session project   # or: <prefix> + P
tmux-personal-session learning  # or: <prefix> + E

# Or use aliases
tmdev
tmproject
tmlearn
```

## 🔐 Secret Management

### Current Approach

Secrets are prompted once during `chezmoi init` and stored in:
```
~/.config/chezmoi/chezmoi.yaml
```

**⚠️ Warning**: This file contains sensitive data! Make sure it's:
1. **.gitignored** - Already configured in `.chezmoiignore`
2. **Encrypted** - Consider using chezmoi's encryption
3. **Backed up securely** - Not synced to GitHub

### Better Secret Management Options

#### Option 1: 1Password Integration

```bash
# In your templates, use:
{{ onepasswordRead "op://vault/item/field" }}

# Example in dot_config/secrets.sh.tmpl:
export ANTHROPIC_API_KEY="{{ onepasswordRead "op://Personal/Anthropic/api_key" }}"
```

#### Option 2: Bitwarden Integration

```bash
# In templates:
{{ bitwardenFields "item-id" }}

# Example:
export GITHUB_TOKEN="{{ (bitwardenFields "github-pat").token }}"
```

#### Option 3: Environment Variables

```bash
# Set in your CI/CD or local environment
export ANTHROPIC_API_KEY="sk-ant-..."

# In template:
{{ if env "ANTHROPIC_API_KEY" }}
export ANTHROPIC_API_KEY="{{ env "ANTHROPIC_API_KEY" }}"
{{ end }}
```

#### Option 4: External Secrets File

Create `~/.config/secrets.sh` (gitignored):

```bash
# ~/.config/secrets.sh
export ANTHROPIC_API_KEY="sk-ant-..."
export GITHUB_TOKEN="ghp_..."
```

This file is already sourced by your `.zshrc`.

### Updating Secrets

```bash
# Reconfigure chezmoi (will re-prompt for secrets)
chezmoi init --promptOnce=false

# Or edit directly
chezmoi edit-config

# Then reapply
chezmoi apply
```

## 🐛 Troubleshooting

### Issue: Changes Not Syncing

```bash
# Check chezmoi status
chezmoi status

# Check git status in chezmoi repo
chezmoi cd && git status

# Force pull
chezmoi git pull --rebase

# Force apply
chezmoi apply --force
```

### Issue: Wrong Machine Context

```bash
# Check current configuration
chezmoi data | grep -A 5 "machine:"

# Reconfigure
chezmoi init --promptOnce=false

# Reapply
chezmoi apply
```

### Issue: Template Errors

```bash
# Check template syntax
chezmoi execute-template < ~/.local/share/chezmoi/dot_zshrc.tmpl

# Verify data
chezmoi data

# Apply with verbose output
chezmoi apply --verbose
```

### Issue: Secrets Not Loading

```bash
# Check secrets file exists
cat ~/.config/secrets.sh

# Check it's being sourced
grep "secrets.sh" ~/.zshrc

# Manually source to test
source ~/.config/secrets.sh
echo $ANTHROPIC_API_KEY
```

### Issue: Tmux Sessions Not Working

```bash
# Check tmux configuration
tmux source ~/.tmux.conf

# Check context-specific config
ls -la ~/.tmux.*.conf

# Test session script
which tmux-work-session
tmux-work-session main
```

## 📚 Quick Reference

### Chezmoi Commands

```bash
cms          # Show chezmoi status
cmsync       # Sync changes with prompt
cmcheck      # Quick check and sync
cma <file>   # Add file to chezmoi
cmd          # Show diff
cme <file>   # Edit file
cmcd         # Enter chezmoi directory
cmup         # Update from repository
```

### Context Commands

```bash
# Check context
echo $MACHINE_CONTEXT
echo $IS_WORK_MACHINE
echo $IS_PERSONAL_MACHINE

# Git context
work_git_config      # Switch to work email
personal_git_config  # Switch to personal email
```

### Tmux Commands

```bash
# Work
tmwork / tmux-work-session main
tmlogs / tmux-work-session logs
tmservices / tmux-work-session services

# Personal
tmdev / tmux-personal-session dev
tmproject / tmux-personal-session project
tmlearn / tmux-personal-session learning
```

## 🎓 Best Practices

### 1. Regular Syncing

```bash
# Add to your daily workflow
# Morning: Pull latest changes
chezmoi update

# Evening: Push your changes
chezmoi cd && git add . && git commit -m "Update configs" && git push
```

### 2. Test Before Pushing

```bash
# Always test changes locally first
chezmoi apply
# Use the configuration for a while
# Then push if everything works
```

### 3. Use Feature Flags

When adding new tools, use feature flags:

```yaml
# .chezmoi.yaml.tmpl
features:
  new_tool: {{ promptBoolOnce . "features.new_tool" "Enable new tool" }}
```

Then in templates:
```bash
{{- if .features.new_tool }}
# New tool configuration
{{- end }}
```

### 4. Document Machine-Specific Changes

When making context-specific changes, document why:

```bash
# In work.zsh
# Company VPN required for internal services
alias vpn-connect="sudo openconnect company.vpn.com"
```

### 5. Keep Secrets Separate

Never commit actual secrets to the repo. Use:
- Secret managers (1Password, Bitwarden)
- Environment variables
- External secret files (.gitignored)

## 📖 Additional Resources

- [Chezmoi Documentation](https://chezmoi.io)
- [Template Syntax](https://chezmoi.io/user-guide/templating/)
- [Secret Management](https://chezmoi.io/user-guide/password-managers/)
- [Managing Different Machines](https://chezmoi.io/user-guide/machines/)

---

**Generated**: 2026-02-05
**For**: Angus Perkerson
**Repository**: https://github.com/angusp/dotfiles
