-- Claude Code CLI integration
-- Keymaps and plugin setup handled by LazyVim extra (ai.claudecode)
-- This file only adds CLAUDE.md filetype enhancements

local M = {}

function M.setup()
  local claude_group = vim.api.nvim_create_augroup("claude_code", { clear = true })

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = claude_group,
    pattern = { "CLAUDE.md", ".claude/**.md" },
    callback = function()
      vim.opt_local.filetype = "markdown"
      vim.opt_local.spell = true
      vim.opt_local.wrap = true
    end,
    desc = "Claude instruction files: markdown + spell",
  })
end

return M
