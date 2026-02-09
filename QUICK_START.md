# Quick Start Guide - Multi-Machine Dotfiles

Fast reference for common tasks across work and personal machines.

## 🚀 Initial Setup (5 minutes)

### New Machine

```bash
# 1. Install chezmoi
brew install chezmoi  # macOS
# or
sh -c "$(curl -fsLS get.chezmoi.io)"  # Linux

# 2. Initialize (will prompt for machine type)
chezmoi init https://github.com/yourusername/dotfiles.git

# 3. Review changes
chezmoi diff

# 4. Apply configuration
chezmoi apply

# 5. Restart shell
exec zsh
```

### Configuration Prompts

**Select wisely - these define your machine:**

| Prompt | Work Machine | Personal Machine |
|--------|--------------|------------------|
| **Context** | `work` | `personal` |
| **Email** | `angus.perkerson@disney.com` | Your personal email |
| **Type** | `development` | `development` |
| **Performance** | `high` | `high` or `medium` |

## 📋 Daily Workflows

### Morning Sync

```bash
# Pull latest changes from other machines
chezmoi update
```

### Evening Push

```bash
# Commit your day's configuration changes
chezmoi cd
git add .
git commit -m "Update config"
git push
exit
```

### Quick Status Check

```bash
# See pending changes
cms

# Auto-sync with confirmation
cmsync
```

## 🔧 Common Tasks

### Edit Configuration

```bash
# Edit zshrc
chezmoi edit ~/.zshrc

# Edit tmux config
chezmoi edit ~/.tmux.conf

# Edit nvim config
chezmoi edit ~/.config/nvim/init.lua
```

### Add New File

```bash
# Add file to chezmoi
chezmoi add ~/.tool-config

# Add as template (for multi-machine)
chezmoi add --autotemplate ~/.gitconfig
```

### Test Changes

```bash
# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Revert if needed
chezmoi forget <file>
```

## 🎯 Context-Specific Commands

### Work Machine

```bash
# Git configuration
work_git_config           # Set work email

# Tmux sessions
tmwork                    # Main work session
tmservices                # Services (backend/frontend/logs)
tmlogs                    # Log monitoring

# Work projects
cdwork                    # Go to work directory
workproject <name>        # Switch to work project
standup                   # Open standup notes
```

### Personal Machine

```bash
# Git configuration
personal_git_config       # Set personal email

# Tmux sessions
tmdev                     # Development session
tmproject                 # Project-specific session
tmlearn                   # Learning session

# Personal projects
proj                      # Go to projects directory
project <name>            # Switch to project with tmux
newproject <name>         # Create new project
learn_note <topic>        # Create learning note
```

## 🔐 Secret Management

### View Secrets Location

```bash
# Check chezmoi config (contains secrets)
cat ~/.config/chezmoi/chezmoi.yaml
```

### Update Secrets

```bash
# Reconfigure (will re-prompt)
chezmoi init --promptOnce=false

# Or edit directly
chezmoi edit-config

# Apply changes
chezmoi apply
```

### External Secrets File

```bash
# Create/edit secrets file
nvim ~/.config/secrets.sh

# Example content:
export ANTHROPIC_API_KEY="sk-ant-..."
export GITHUB_TOKEN="ghp_..."

# This file is automatically sourced by .zshrc
```

## 🐛 Troubleshooting

### Not Syncing?

```bash
chezmoi git pull --rebase
chezmoi apply --force
```

### Wrong Context?

```bash
# Check current
echo $MACHINE_CONTEXT

# Reconfigure
chezmoi init --promptOnce=false
chezmoi apply
```

### Template Errors?

```bash
# Test template
chezmoi execute-template < ~/.local/share/chezmoi/dot_zshrc.tmpl

# Check data
chezmoi data

# Apply with debug
chezmoi apply --verbose
```

## 🎨 Customization

### Add Work-Specific Alias

Edit `~/.config/zsh/work.zsh`:
```bash
chezmoi cd
nvim dot_config/zsh/work.zsh
# Add your aliases
git add . && git commit -m "Add work aliases" && git push
exit
```

### Add Personal Tool

Edit `~/.config/zsh/personal.zsh`:
```bash
chezmoi cd
nvim dot_config/zsh/personal.zsh
# Add your tool config
git add . && git commit -m "Add personal tool" && git push
exit
```

### Create Custom Tmux Session

**Work:**
```bash
nvim ~/.local/share/chezmoi/dot_tmux.work.conf
```

**Personal:**
```bash
nvim ~/.local/share/chezmoi/dot_tmux.personal.conf
```

## 📱 Machine Context Cheat Sheet

### Environment Variables

```bash
$MACHINE_CONTEXT          # "work" or "personal"
$MACHINE_TYPE             # "development", "server", etc.
$MACHINE_PERFORMANCE      # "high", "medium", "low"
$IS_WORK_MACHINE          # true/false
$IS_PERSONAL_MACHINE      # true/false
```

### In Scripts

```bash
if [[ "$MACHINE_CONTEXT" == "work" ]]; then
    # Work-specific logic
else
    # Personal-specific logic
fi
```

### In Templates

```bash
{{- if .machine.isWork }}
# Work configuration
{{- else }}
# Personal configuration
{{- end }}
```

## 🔄 Sync Workflow Diagram

```
┌─────────────────────────────────────────┐
│  Work Machine                           │
│                                         │
│  1. Make changes to configs             │
│  2. chezmoi cd && git add/commit/push   │
│                                         │
└───────────────┬─────────────────────────┘
                │
                │ Git Push
                ▼
         ┌──────────────┐
         │  GitHub      │
         │  Repository  │
         └──────────────┘
                │
                │ Git Pull
                ▼
┌─────────────────────────────────────────┐
│  Personal Machine                       │
│                                         │
│  1. chezmoi update                      │
│  2. Configs automatically applied       │
│                                         │
└─────────────────────────────────────────┘
```

## 🎯 Pro Tips

1. **Sync Often** - Pull in the morning, push at night
2. **Test First** - Always `chezmoi diff` before `apply`
3. **Context Aware** - Use `work.zsh` and `personal.zsh` for context-specific configs
4. **Tmux Sessions** - Leverage pre-configured sessions for faster setup
5. **Feature Flags** - Use them to enable/disable tools per machine
6. **Document** - Add comments explaining machine-specific hacks
7. **Backup Secrets** - Keep `chezmoi.yaml` backed up securely

## 📚 Key Files

```
~/.zshrc                              # Main shell config (templated)
~/.zshenv                             # Environment variables (templated)
~/.tmux.conf                          # Tmux config (templated)
~/.config/zsh/work.zsh                # Work-specific shell config
~/.config/zsh/personal.zsh            # Personal-specific shell config
~/.config/chezmoi/chezmoi.yaml        # Your machine's config + secrets
~/.local/share/chezmoi/               # Chezmoi source repository
~/.config/secrets.sh                  # External secrets (gitignored)
```

## 🆘 Get Help

```bash
# Chezmoi help
chezmoi help

# Check configuration
chezmoi doctor

# View template data
chezmoi data

# Execute template for debugging
chezmoi execute-template < template-file.tmpl
```

---

**Quick Links:**
- [Full Multi-Machine Guide](./MULTI_MACHINE_GUIDE.md)
- [Chezmoi Documentation](https://chezmoi.io)
- [Repository README](./README.md)
