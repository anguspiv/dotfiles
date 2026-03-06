-- Autocmds for enhanced functionality and performance

local function augroup(name)
  return vim.api.nvim_create_augroup("neovim_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  command = "checktime",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- TypeScript/JavaScript specific autocmds
-- Skip format-on-save when in VSCode/Cursor (let the editor handle it)
local is_vscode = vim.g.vscode == 1

if not is_vscode then
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("typescript_javascript"),
    pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
    callback = function()
      -- Enable format on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = 0,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
      
      -- Organize imports on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = 0,
        callback = function()
          vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" } },
            apply = true,
          })
        end,
      })
    end,
  })
end

-- Performance: disable syntax highlighting for large files
vim.api.nvim_create_autocmd("BufReadPre", {
  group = augroup("large_files"),
  callback = function(args)
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > 1000000 then -- 1MB
      vim.cmd("syntax off")
      vim.cmd("IlluminatePauseBuf") -- disable vim-illuminate
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

    -- Set window-local highlights for terminal buffers
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

-- Neo-tree visual distinction
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("neotree_setup"),
  pattern = "neo-tree",
  callback = function()
    vim.opt_local.signcolumn = "no"
    -- Set window-local highlights for neo-tree
    vim.wo.winhighlight = "Normal:NeoTreeNormal,NormalNC:NeoTreeNormalNC,EndOfBuffer:NeoTreeEndOfBuffer"
  end,
})
