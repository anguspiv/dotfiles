-- AI plugin customizations on top of the LazyVim ai.claudecode extra
return {
  -- Claude Code: diff opens in a new tab so both sides are adjacent (not split around the terminal)
  {
    "coder/claudecode.nvim",
    opts = {
      diff_opts = {
        open_in_new_tab = true,
        hide_terminal_in_new_tab = true,
      },
    },
  },
}
