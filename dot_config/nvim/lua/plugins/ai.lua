-- AI plugin customizations on top of LazyVim extras (ai.copilot, ai.claudecode)
-- LazyVim uses zbirenbaum/copilot.lua, so we configure that instead of copilot.vim
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

  -- Copilot: custom accept keymaps and filetype restrictions
  {
    "zbirenbaum/copilot.lua",
    opts = {
      filetypes = {
        ["*"] = false,
        javascript = true,
        typescript = true,
        javascriptreact = true,
        typescriptreact = true,
        python = true,
        lua = true,
        rust = true,
        go = true,
        html = true,
        css = true,
        scss = true,
        json = true,
        markdown = true,
      },
      copilot_node_command = vim.fn.expand("~/.local/share/fnm/node-versions/v22.22.0/installation/bin/node"),
    },
  },
}
