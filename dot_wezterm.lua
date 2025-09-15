local wezterm = require 'wezterm'

return {
  -- Victor Mono Nerd Font with ligatures
  font = wezterm.font('VictorMono Nerd Font', {
    weight = 'Regular',
    italic = false,
  }),
  font_size = 14.0,
  
  -- Enable ligatures properly for Victor Mono
  harfbuzz_features = { 'calt=1', 'liga=1', 'dlig=1', 'ss01=1' },
  
  -- Gruvbox dark theme - retro warm earth tones
  color_scheme = 'Breath Darker (Gogh)', -- 'Blue Matrix', 
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
