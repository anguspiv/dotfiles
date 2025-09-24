# ZPlug Plugin Configuration

# ZPLUG Setup
export ZPLUG_HOME=$(brew --prefix)/opt/zplug
source $ZPLUG_HOME/init.zsh

## ZPlug Plugins with optimized loading

# Performance-focused plugins with defer levels
zplug "hlissner/zsh-autopair", defer:2
zplug "cpitt/zsh-dotenv", as:plugin, defer:1
zplug "z-shell/zsh-diff-so-fancy", as:command, use:"bin/", defer:3
zplug "zdharma-continuum/fast-syntax-highlighting", defer:2

# Load plugins
zplug load