-- Claude Code CLI integration
-- Handles terminal workflow, filetype enhancements, and working directory awareness
-- for the Claude Code CLI tool (distinct from CopilotChat/claude.vim in config/ai.lua)

local M = {}

--- Find the git root of the given path, or fall back to cwd
local function get_project_root()
  local result = vim.fn.systemlist("git -C " .. vim.fn.shellescape(vim.fn.getcwd()) .. " rev-parse --show-toplevel 2>/dev/null")
  if vim.v.shell_error == 0 and result[1] then
    return result[1]
  end
  return vim.fn.getcwd()
end

--- Open Claude Code in a terminal, rooted at the project root
local function open_claude(in_tab)
  local root = get_project_root()
  local cmd = "lcd " .. vim.fn.fnameescape(root) .. " | term claude"
  if in_tab then
    vim.cmd("tabnew | " .. cmd)
  else
    vim.cmd("botright split | " .. cmd)
  end
  vim.cmd("startinsert")
end

function M.setup()
  -- Only activate when the claude CLI is available
  if vim.fn.executable("claude") ~= 1 then
    return
  end

  local keymap = vim.keymap.set

  -- Terminal integration
  keymap("n", "<leader>ac", function() open_claude(false) end, { desc = "Claude Code (split)" })
  keymap("n", "<leader>aC", function() open_claude(true) end,  { desc = "Claude Code (tab)" })

  -- CLAUDE.md filetype enhancements
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
