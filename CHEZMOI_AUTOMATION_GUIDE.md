# Chezmoi Automation & Sync Guide

Complete guide for automating chezmoi syncing with reminders, auto-commits, and monitoring.

## 🎯 Automation Strategies

Choose the approach that fits your workflow:

1. **Gentle Reminders** (Recommended) - Get notified, you decide
2. **Prompted Sync** - Asked to sync when changes detected
3. **Auto-Sync** - Fully automated (use with caution)
4. **Manual with Helpers** - Enhanced manual workflow

## 🔔 Strategy 1: Gentle Reminders (Recommended)

### Shell Startup Reminders

**Already configured!** On shell startup, you'll see:
```
📝 Chezmoi: You have uncommitted changes. Run 'cms' to see them.
```

### Daily Reminders via Cron

Get reminded twice daily (morning and evening) if you have changes:

```bash
# Install the reminder script
chmod +x ~/.local/bin/chezmoi-daily-reminder

# Add to crontab
crontab -e

# Add these lines:
# Morning reminder (9 AM)
0 9 * * * ~/.local/bin/chezmoi-daily-reminder

# Evening reminder (5 PM)
0 17 * * * ~/.local/bin/chezmoi-daily-reminder
```

**What it does:**
- Checks once per day
- Sends desktop notification if changes detected
- Logs reminders to `~/.cache/chezmoi_reminders.log`
- Non-intrusive - just a notification

### Tmux Statusline Indicator

Shows chezmoi status in your tmux statusline:

```bash
# Enable in tmux.conf
# The optimized config already includes this!

# Status shows:
# ✓       - All synced
# 📝 3    - 3 local changes
# ⬇️ 2    - 2 remote updates
# 📝 3↓2  - Both local changes and remote updates
```

**Already included** in `dot_tmux.conf.optimized`!

## ⚡ Strategy 2: Prompted Auto-Sync

Get prompted to sync automatically when changes are detected:

### Enable in Your Shell

Add to `~/.zshrc` (or the optimized template already includes it):

```bash
# Load chezmoi auto-sync
source ~/.config/zsh/chezmoi-auto-sync.zsh

# Set sync mode to prompt
export CHEZMOI_SYNC_MODE="prompt"

# Check interval (in seconds)
export CHEZMOI_CHECK_INTERVAL=3600  # 1 hour
```

**What it does:**
- Checks every hour (configurable)
- Prompts: "Pull updates now? (y/N)"
- Prompts: "Sync changes now? (y/N)"
- You still have control

### Enable Periodic Background Check

Uncomment in `chezmoi-auto-sync.zsh`:

```bash
# At the bottom of the file, uncomment:
_chezmoi_start_periodic_check
```

## 🤖 Strategy 3: Auto-Sync (Advanced)

Fully automated syncing - use with caution:

```bash
# In ~/.zshrc
source ~/.config/zsh/chezmoi-auto-sync.zsh
export CHEZMOI_SYNC_MODE="auto"
```

**What it does:**
- Automatically pulls remote updates
- **Does NOT** auto-push (safety measure)
- Best for single-user setups

**⚠️ Warning**: Can cause conflicts if you work on multiple machines simultaneously.

## 🛠️ Strategy 4: Enhanced Manual Workflow

Best for maximum control with helpful tools:

### Quick Commands

```bash
# Check status
cms                 # Show chezmoi status

# Smart sync (interactive)
cmsync              # Full sync with prompts

# Quick check
cmcheck             # Force a status check now

# Pull only
cmpull              # Pull remote updates

# Push only
cmpush              # Push local commits
```

### Auto-Commit with Smart Messages

Automatically generate good commit messages:

```bash
# Commit with auto-generated message
chezmoi-auto-commit

# Auto-commit and auto-push
AUTO_PUSH=true chezmoi-auto-commit
```

**Smart messages** based on what changed:
- "Update zsh configuration"
- "Update tmux configuration"
- "Update neovim configuration"
- "Update dotfiles (3 files changed)"

### Git Hooks for Auto-Commit

Automatically commit when files change:

```bash
# Enter chezmoi directory
chezmoi cd

# Create pre-commit hook (runs on `chezmoi apply`)
cat > .git/hooks/post-merge <<'EOF'
#!/bin/bash
# Auto-apply after pulling updates
chezmoi apply
EOF
chmod +x .git/hooks/post-merge

# Exit chezmoi directory
exit
```

## 📊 Monitoring & Visibility

### Check Sync Status Anytime

```bash
# Quick status
cms

# Detailed status
chezmoi status

# See what would change
chezmoi diff

# Check remote
chezmoi cd && git fetch && git status
```

### View Reminder Log

```bash
# See all reminders
cat ~/.cache/chezmoi_reminders.log

# See today's reminders
grep "$(date +%Y-%m-%d)" ~/.cache/chezmoi_reminders.log
```

### Tmux Integration

Your tmux statusline shows real-time chezmoi status:

```
🏢 WORK | work-main | ~/projects ⚡ v20.11.0 | 📝 3 | WiFi | 🔋 87% | 45% | 14:30
                                              ^^^^
                                        Chezmoi status
```

## 🔄 Recommended Workflow

### Morning Routine

```bash
# 1. Open terminal (automatic check on startup)
# 2. If notification/prompt appears:
chezmoi update      # Pull latest changes
chezmoi diff        # Review what changed
chezmoi apply       # Apply changes

# 3. Start working
tmwork             # or tmdev
```

### During the Day

Work normally - you'll see status in tmux statusline:
- ✓ - All good
- 📝 - Local changes (commit when ready)
- ⬇️ - Updates available (pull when convenient)

### Evening Routine

```bash
# 1. Check what you changed today
cms

# 2. Sync changes
cmsync             # Interactive sync with prompts

# Or manual:
chezmoi cd
git add .
git commit -m "Update configs from today's work"
git push
exit
```

## ⚙️ Configuration Options

All settings in `~/.config/zsh/chezmoi-auto-sync.zsh`:

### Sync Modes

```bash
# Notify only (default, safest)
export CHEZMOI_SYNC_MODE="notify"

# Prompt to sync
export CHEZMOI_SYNC_MODE="prompt"

# Auto-sync (advanced)
export CHEZMOI_SYNC_MODE="auto"
```

### Check Interval

```bash
# Check every 30 minutes
export CHEZMOI_CHECK_INTERVAL=1800

# Check every 2 hours
export CHEZMOI_CHECK_INTERVAL=7200

# Check every 6 hours
export CHEZMOI_CHECK_INTERVAL=21600
```

### Startup Check

```bash
# Enable startup check (default)
export CHEZMOI_STARTUP_CHECK=true

# Disable startup check
export CHEZMOI_STARTUP_CHECK=false
```

### Enable Features

```bash
# In ~/.zshrc, uncomment to enable:

# Background periodic checking
_chezmoi_start_periodic_check

# Check on directory change
autoload -U add-zsh-hook
add-zsh-hook chpwd _chezmoi_chpwd_check
```

## 🐛 Troubleshooting

### Reminders Not Showing

```bash
# Check if script is executable
ls -la ~/.local/bin/chezmoi-daily-reminder

# Test the script
~/.local/bin/chezmoi-daily-reminder

# Check cron logs (macOS)
log show --predicate 'process == "cron"' --last 1h

# Check cron logs (Linux)
grep CRON /var/log/syslog | tail
```

### Auto-Sync Not Working

```bash
# Check if loaded
typeset -f _chezmoi_auto_check

# Check mode
echo $CHEZMOI_SYNC_MODE

# Force a check
cmcheck

# Check last check time
cat ~/.cache/chezmoi_last_check
```

### Notifications Not Appearing

**macOS:**
```bash
# Check notification permissions
# System Preferences > Notifications > Terminal (or your terminal app)
# Make sure "Allow Notifications" is enabled
```

**Linux:**
```bash
# Check if notify-send works
notify-send "Test" "This is a test notification"

# Install if missing
sudo apt install libnotify-bin  # Debian/Ubuntu
sudo dnf install libnotify       # Fedora
```

### Tmux Status Not Updating

```bash
# Check script is executable
ls -la ~/.tmux/scripts/chezmoi_status_enhanced.sh

# Test script
~/.tmux/scripts/chezmoi_status_enhanced.sh

# Clear cache
rm ~/.cache/tmux_chezmoi_status

# Reload tmux
tmux source ~/.tmux.conf
```

## 📋 Quick Setup Checklist

Choose your level of automation:

### Level 1: Basic (Manual with reminders)

- [x] Startup reminders (already enabled)
- [ ] Add cron jobs for daily reminders
- [ ] Use `cms` and `cmsync` commands

### Level 2: Assisted (Prompted sync)

- [ ] Enable `chezmoi-auto-sync.zsh`
- [ ] Set `CHEZMOI_SYNC_MODE="prompt"`
- [ ] Enable background checking
- [ ] Add tmux statusline indicator

### Level 3: Automated (Full auto-sync)

- [ ] Enable `chezmoi-auto-sync.zsh`
- [ ] Set `CHEZMOI_SYNC_MODE="auto"`
- [ ] Set up git hooks
- [ ] Configure `AUTO_PUSH=true`

**Recommendation**: Start with Level 1, move to Level 2 after a week.

## 🎓 Pro Tips

1. **Start Conservative** - Begin with notify mode, upgrade to prompt mode
2. **Watch Tmux Status** - Glance at statusline to stay aware
3. **Sync Before Major Changes** - Always `cmsync` before big edits
4. **Use Smart Commits** - Let `chezmoi-auto-commit` write good messages
5. **Set Reminders** - Cron reminders are non-intrusive and effective
6. **Check Before Sleep** - Quick `cmsync` before closing your laptop
7. **Morning Pull** - Start each day with `chezmoi update`

## 🔗 Related Documentation

- [MULTI_MACHINE_GUIDE.md](./MULTI_MACHINE_GUIDE.md) - Multi-machine setup
- [QUICK_START.md](./QUICK_START.md) - Quick reference
- [README.md](./README.md) - Main documentation

---

**Quick Commands Reference:**

```bash
# Status & Check
cms                 # Show status
cmcheck             # Force check now

# Sync
cmsync              # Full interactive sync
cmpull              # Pull updates only
cmpush              # Push commits only

# Auto-commit
chezmoi-auto-commit # Smart commit message
AUTO_PUSH=true chezmoi-auto-commit  # Commit and push

# Configuration
echo $CHEZMOI_SYNC_MODE         # Check current mode
echo $CHEZMOI_CHECK_INTERVAL    # Check interval
```

---

Stay in sync effortlessly! 🚀
