# ✅ Tmux Statusline - Improved!

Your tmux statusline has been upgraded with better chezmoi integration and git awareness.

## 📊 What You'll See

### Left Side (Session Info)
```
[work-main] ~/projects main* | ⚡v20.11.0
 ^^^^^^^^^  ^^^^^^^^^ ^^^^     ^^^^^^^^^^
 Session    Directory Git      Node.js
 name       path      branch   version
                      with     
                      changes  
```

### Right Side (System Info)
```
📝 3 | WiFi 🔒 | 🔋87% | 45% 38% | 14:30 | 02/05
^^^^   ^^^^^^^^   ^^^^^   ^^^^^^^^  ^^^^^   ^^^^^
Chezm  Network   Battery CPU/Mem   Time    Date
Status + VPN      Level   Usage
```

## 🎨 Chezmoi Status Indicators

### ✓ All Synced (Green)
```
✓ | WiFi | 🔋87% | ...
```
**Meaning**: Everything is committed and synced. You're good! 😊

### 📝 Local Changes (Yellow)
```
📝 3 | WiFi | 🔋87% | ...
```
**Meaning**: You have 3 uncommitted dotfile changes on this machine.
**Action**: Run `cmsync` when ready to commit.

### ⬇️ Remote Updates (Blue)
```
⬇️ 2 | WiFi | 🔋87% | ...
```
**Meaning**: Your other machine pushed 2 updates.
**Action**: Run `chezmoi update` to pull them.

### 📝 Both (Yellow with Down Arrow)
```
📝 3↓2 | WiFi | 🔋87% | ...
```
**Meaning**: 
- 3 local changes to commit
- 2 remote updates to pull
**Action**: 
1. `chezmoi update` (pull first)
2. `cmsync` (then commit your changes)

## 🔍 Git Branch Indicator

Shows in directory section:

```
~/projects main      ← Clean, on 'main' branch
~/projects main*     ← Dirty, has uncommitted changes
~/projects feature   ← On 'feature' branch
~/projects           ← Not in a git repo
```

## 🚀 Key Improvements

### 1. Better Chezmoi Detection
- **Old**: Checked every 10 seconds (slow, inaccurate)
- **New**: Cached for 5 minutes, checks remote updates
- **Impact**: 97% fewer checks, more accurate count

### 2. Remote Update Awareness
- **Old**: Only knew about local changes
- **New**: Tells you when other machine has updates
- **Impact**: Never miss syncing from your other machine!

### 3. Visual Feedback
- **Old**: Red (alarming) or nothing
- **New**: 
  - Green ✓ = confidence everything is synced
  - Yellow 📝 = informational, take action when ready
  - Blue ⬇️ = updates available

### 4. Git Branch Context
- **New**: Always know what branch you're on
- **Impact**: Prevents "wrong branch" commits

## 📋 Quick Reference

### Status Bar Layout
```
┌─────────────── LEFT ───────────────┬──────────────── RIGHT ─────────────────┐
│ [SESSION] ~/dir branch | node ver  │ dotfiles|net|bat|sys| time | date     │
└────────────────────────────────────┴────────────────────────────────────────┘
```

### Chezmoi Status Quick Guide
| Display | Meaning | Action |
|---------|---------|--------|
| `✓` | Synced | None - keep working! |
| `📝 3` | 3 local | `cmsync` to commit |
| `⬇️ 2` | 2 remote | `chezmoi update` to pull |
| `📝 3↓2` | Both | Pull first, then commit |

### Git Branch Quick Guide
| Display | Meaning |
|---------|---------|
| `main` | On main, clean |
| `main*` | On main, dirty |
| `feature` | On feature branch |
| (empty) | Not in git repo |

## 💡 Pro Tips

1. **Glance at statusline** before starting work
   - ⬇️ means pull updates from other machine first
   
2. **Watch git branch** to avoid wrong-branch commits
   - See `main*` but want to commit to feature? Switch branches!
   
3. **Green ✓ is your friend** 
   - Means you can close laptop without worry
   
4. **Combined status** `📝 3↓2` means:
   - Pull first (`chezmoi update`)
   - Then handle your local changes (`cmsync`)

## 🧪 Test It

### In tmux, try:

```bash
# See your statusline
tmux display-message -p '#{status-left} #{status-right}'

# Make a change to trigger chezmoi status
echo "# test" >> ~/.zshrc

# Wait a moment and check statusline
# Should show 📝 1

# Check from terminal
~/.tmux/scripts/chezmoi_status_enhanced.sh
```

### Navigate directories:

```bash
# Go to a git repo
cd ~/projects/your-repo

# Watch statusline - should show branch name
# Make a change
echo "test" >> README.md

# Watch statusline - should show branch*
```

## 🔧 Configuration

All scripts located in:
```
~/.tmux/scripts/
├── chezmoi_status_enhanced.sh    ← New enhanced version
├── git_branch.sh                  ← New git branch indicator
├── chezmoi_status.sh              ← Old version (kept as backup)
├── node_version_cross.sh          ← Node.js version
├── network_status_cross.sh        ← Network + VPN
├── battery_status_cross.sh        ← Battery level
└── system_stats_cross.sh          ← CPU/Memory usage
```

### Adjust Caching

Edit script files to change cache times:

**Chezmoi Status** (5 minutes):
```bash
# In chezmoi_status_enhanced.sh
CACHE_TTL=300  # Change to 600 for 10 minutes
```

**Git Branch** (5 seconds):
```bash
# In git_branch.sh
CACHE_TTL=5  # Change to 10 for longer cache
```

### Customize Colors

Edit `~/.tmux.conf`:

```bash
# Find these lines and adjust colors:
#[fg=#a3be8c]  # Green for git branch
#[fg=#ebcb8b]  # Yellow for local changes
#[fg=#5e81ac]  # Blue for remote updates
```

## 🎓 Understanding the Output

### Example Scenarios

**Scenario 1: Working Solo**
```
[dev] ~/project main* | node-20 | 📝 2 | WiFi | ...
```
- On main branch with local changes
- 2 uncommitted dotfile changes
- No remote updates

**Scenario 2: Other Machine Updated**
```
[dev] ~/project | node-20 | ⬇️ 5 | WiFi | ...
```
- Other machine pushed 5 changes
- Your local dotfiles are clean
- Run `chezmoi update` to get changes

**Scenario 3: Both Machines Active**
```
[dev] ~/project feature* | node-20 | 📝 3↓2 | WiFi | ...
```
- Working on feature branch (dirty)
- 3 local dotfile changes
- 2 remote updates available
- Action: Pull updates, then commit yours

**Scenario 4: All Good**
```
[dev] ~/project main | node-20 | ✓ | WiFi | ...
```
- Clean git repo on main
- All dotfiles synced
- Can close laptop worry-free! 😊

## 🐛 Troubleshooting

### Chezmoi Status Not Updating?

```bash
# Clear cache
rm ~/.cache/tmux_chezmoi_status

# Force refresh (wait 10 seconds for tmux to update)
```

### Git Branch Not Showing?

```bash
# Test manually
cd ~/your-repo
~/.tmux/scripts/git_branch.sh "$(pwd)"

# Check if script is executable
ls -la ~/.tmux/scripts/git_branch.sh
```

### Want Old Behavior Back?

```bash
# Restore backup
cp ~/.tmux.conf.backup ~/.tmux.conf
tmux source ~/.tmux.conf
```

## 📚 Related Commands

```bash
# Chezmoi
cmsync              # Interactive sync
chezmoi update      # Pull remote changes
chezmoi status      # Check status

# Git
git status          # Check repo status
git branch          # See all branches

# Tmux
tmux source ~/.tmux.conf    # Reload config
Ctrl-b r                     # Reload (keybinding)
```

---

**Your statusline is now supercharged!** 🚀

Watch it work for you as you develop across machines.
