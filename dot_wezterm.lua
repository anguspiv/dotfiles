local wezterm = require 'wezterm'

return {
  -- Font consistency with Ghostty  
  font = wezterm.font('Monaspace Neon', {
    weight = 'Regular',
  }),
  font_size = 14.0,
  
  -- Colors to match tmux Nordic theme
  color_scheme = 'nord',
  enable_tab_bar = false,
  
  -- Terminal integration - use standard term type (fixes typing issues)
  term = 'xterm-256color',
  
  -- Performance
  max_fps = 60,
  front_end = 'WebGpu',
  
  -- Tmux-friendly settings
  use_dead_keys = false,
  scrollback_lines = 50000,
  
  -- Key handling
  send_composed_key_when_left_alt_is_pressed = false,
  send_composed_key_when_right_alt_is_pressed = false,
}