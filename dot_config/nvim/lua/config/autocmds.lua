-- Custom autocmds (non-LazyVim-default)
-- LazyVim already provides: highlight yank, resize splits, last loc,
-- close with q, wrap/spell for text, auto create dir, checktime

local function augroup(name)
  return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("trim_whitespace"),
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Performance: disable syntax highlighting for large files
vim.api.nvim_create_autocmd("BufReadPre", {
  group = augroup("large_files"),
  callback = function(args)
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > 1000000 then
      vim.cmd("syntax off")
      pcall(vim.cmd, "IlluminatePauseBuf")
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.spell = false
    end
  end,
})

-- Terminal buffer visual distinction
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("terminal_setup"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.wo.winhighlight = "Normal:TerminalNormal,NormalNC:TerminalNormalNC"
  end,
})

-- Auto enter insert mode when switching to terminal buffer
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  group = augroup("terminal_insert"),
  pattern = "term://*",
  callback = function()
    vim.cmd("startinsert")
  end,
})

-- Keep terminal in insert mode when leaving and re-entering
vim.api.nvim_create_autocmd("BufLeave", {
  group = augroup("terminal_leave"),
  pattern = "term://*",
  callback = function()
    vim.cmd("stopinsert")
  end,
})
