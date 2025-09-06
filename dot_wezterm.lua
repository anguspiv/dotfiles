local wezterm = require 'wezterm'

return {
  -- Font consistency with Ghostty
  font = wezterm.font('MonaspiceNE Nerd Font', {
    weight = 'Regular',
  }),
  font_size = 14.0,
  
  -- Enable ligatures and font features
  harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' },
  
  -- Tmux integration
  unix_domains = {
    {
      name = 'unix',
    },
  },
  default_gui_startup_args = { 'connect', 'unix' },
  
  -- Terminal integration
  term = 'wezterm',
  enable_tab_bar = false, -- Since you use tmux
  
  -- Colors to match tmux Nordic theme
  color_scheme = 'nord',
  
  -- Performance
  max_fps = 60,
  front_end = 'WebGpu',
  
  -- Tmux-friendly settings
  use_dead_keys = false,
  scrollback_lines = 50000, -- Match tmux history
  
  -- Key handling
  send_composed_key_when_left_alt_is_pressed = false,
  send_composed_key_when_right_alt_is_pressed = false,
}