# Chezmoi Automation - Quick Start

**Goal**: Never forget to sync your dotfiles between machines.

## 🚀 5-Minute Setup (Recommended)

### Step 1: Enable Daily Reminders

Get notified twice daily if you have unsync'd changes:

```bash
# Make script executable (already done in chezmoi)
chmod +x ~/.local/bin/chezmoi-daily-reminder

# Add to crontab
crontab -e

# Add these two lines:
0 9 * * * ~/.local/bin/chezmoi-daily-reminder
0 17 * * * ~/.local/bin/chezmoi-daily-reminder
```

**Result**: You'll get a desktop notification at 9 AM and 5 PM if you have changes to sync.

### Step 2: Enable Startup Reminders

Already enabled! When you open a new terminal:

```bash
# If you have changes, you'll see:
📝 Chezmoi: You have uncommitted changes. Run 'cms' to see them.
```

### Step 3: Add to Your .zshrc

Add this line to your `~/.zshrc` (or it's already in the optimized template):

```bash
# Load chezmoi auto-sync (with gentle reminders)
source ~/.config/zsh/chezmoi-auto-sync.zsh
```

**Done!** Restart your shell:
```bash
exec zsh
```

## 🎯 What You Get

### 1. Shell Startup Check
```
$ zsh
📝 Chezmoi: You have uncommitted changes. Run 'cms' to see them.
```

### 2. Daily Notifications

**Morning (9 AM):**
```
┌─────────────────────────────┐
│ Chezmoi Reminder            │
├─────────────────────────────┤
│ Local Changes               │
│ You have uncommitted        │
│ dotfile changes.            │
│ Open terminal and run       │
│ 'cmsync'                    │
└─────────────────────────────┘
```

**Evening (5 PM):**
```
┌─────────────────────────────┐
│ Chezmoi Reminder            │
├─────────────────────────────┤
│ Remote Updates              │
│ Your dotfiles have 2        │
│ update(s). Open terminal    │
│ and run 'chezmoi update'    │
└─────────────────────────────┘
```

### 3. Quick Commands

```bash
cms         # Check status
cmsync      # Interactive full sync
cmpull      # Pull updates
cmpush      # Push commits
cmcheck     # Force status check
```

### 4. Smart Auto-Commit

```bash
# Instead of manual git commands:
chezmoi-auto-commit

# Output:
# 📝 Changes detected:
#  M dot_zshrc.tmpl
#  M dot_tmux.conf
# ✅ Committed: Update zsh and tmux configuration
# Push to remote? (y/N):
```

## ⚡ Optional: More Automation

### Option A: Tmux Statusline Indicator

See chezmoi status in your tmux bar:

```
🏢 WORK | ~/project | 📝 3 | ...
                      ^^^^
                      3 uncommitted changes
```

**Already included** in the optimized tmux config!

### Option B: Prompted Auto-Sync

Get prompted to sync every hour:

```bash
# Add to ~/.zshrc:
export CHEZMOI_SYNC_MODE="prompt"
export CHEZMOI_CHECK_INTERVAL=3600  # 1 hour

# Uncomment in chezmoi-auto-sync.zsh:
_chezmoi_start_periodic_check
```

### Option C: Full Auto-Sync (Advanced)

Automatically pull updates (doesn't auto-push):

```bash
# Add to ~/.zshrc:
export CHEZMOI_SYNC_MODE="auto"
```

⚠️ **Caution**: Can cause conflicts if editing on multiple machines simultaneously.

## 📋 Daily Workflow

### Morning
```bash
# 1. Open terminal
# 2. See reminder if needed
# 3. Pull updates
chezmoi update

# 4. Start work
tmwork  # or tmdev
```

### During Day

Glance at tmux statusline:
- ✓ = All synced
- 📝 3 = 3 local changes
- ⬇️ 2 = 2 remote updates

### Evening
```bash
# Sync your changes
cmsync

# Or manual:
cms              # See what changed
chezmoi cd
git add .
git commit -m "Update configs"
git push
```

## 🔧 Configuration

### Sync Modes

```bash
# Notify only (default - safest)
export CHEZMOI_SYNC_MODE="notify"

# Prompt to sync (convenient)
export CHEZMOI_SYNC_MODE="prompt"

# Auto-sync (advanced)
export CHEZMOI_SYNC_MODE="auto"
```

### Check Frequency

```bash
# Check every 30 minutes
export CHEZMOI_CHECK_INTERVAL=1800

# Check every 2 hours
export CHEZMOI_CHECK_INTERVAL=7200
```

### Disable Features

```bash
# Disable startup check
export CHEZMOI_STARTUP_CHECK=false
```

## 🐛 Troubleshooting

### No Notifications?

**macOS:**
```bash
# Go to: System Preferences > Notifications > Terminal
# Enable "Allow Notifications"
```

**Linux:**
```bash
# Install notification tool
sudo apt install libnotify-bin
```

### Test Notifications

```bash
# Run the reminder script manually
~/.local/bin/chezmoi-daily-reminder

# Test system notifications
osascript -e 'display notification "Test" with title "Test"'  # macOS
notify-send "Test" "Test message"  # Linux
```

### Check Cron

```bash
# List your crontab
crontab -l

# Check cron is running
ps aux | grep cron
```

## 💡 Pro Tips

1. **Start Simple** - Just enable daily reminders first
2. **Check Before Bed** - Quick `cmsync` before closing laptop
3. **Morning Sync** - Start day with `chezmoi update`
4. **Use Smart Commits** - `chezmoi-auto-commit` writes good messages
5. **Watch Tmux** - Glance at statusline throughout the day
6. **Set and Forget** - Once configured, it just works

## 📚 Full Documentation

For complete details, see:
- [CHEZMOI_AUTOMATION_GUIDE.md](./CHEZMOI_AUTOMATION_GUIDE.md) - Complete automation guide
- [MULTI_MACHINE_GUIDE.md](./MULTI_MACHINE_GUIDE.md) - Multi-machine setup
- [QUICK_START.md](./QUICK_START.md) - General quick start

---

**That's it!** You're now set up with automated reminders. You'll never forget to sync your dotfiles again. 🎉
