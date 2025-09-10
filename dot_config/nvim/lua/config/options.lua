-- Core Neovim Options
-- Optimized for performance and modern development

local opt = vim.opt

-- General
opt.mouse = "a" -- Enable mouse support
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.swapfile = false -- Disable swap files
opt.backup = false -- Disable backup files
opt.undofile = true -- Enable persistent undo
opt.updatetime = 250 -- Faster completion (4000ms default)
opt.timeoutlen = 300 -- Time to wait for a mapped sequence
opt.autowrite = true -- Enable auto write
opt.confirm = true -- Confirm to save changes before exiting modified buffer

-- UI
opt.number = true -- Print line number
opt.relativenumber = true -- Relative line numbers
opt.signcolumn = "yes" -- Always show the signcolumn
opt.cursorline = true -- Enable highlighting of the current line
opt.termguicolors = true -- True color support
opt.winminwidth = 5 -- Minimum window width
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.showmode = false -- Don't show mode since we have a statusline
opt.conceallevel = 2 -- Hide concealed text

-- Command-line completion
opt.wildmenu = true -- Show command completions
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.wildoptions = "pum" -- Use popup menu for command completion

-- Indentation
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Size of an indent
opt.tabstop = 2 -- Number of spaces tabs count for
opt.softtabstop = 2 -- Number of spaces that <Tab> uses while editing
opt.smartindent = true -- Insert indents automatically
opt.shiftround = true -- Round indent

-- Search
opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Don't ignore case with capitals
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"

-- Completion
opt.completeopt = "menu,menuone,noselect"
opt.wildmode = "longest:full,full" -- Command-line completion mode

-- Splits
opt.splitright = true -- Put new windows right of current
opt.splitbelow = true -- Put new windows below current

-- Performance
-- opt.lazyredraw = true -- Don't redraw while executing macros (disabled for Noice compatibility)
opt.ttyfast = true -- Send more characters for redraws
opt.synmaxcol = 300 -- Don't syntax highlight long lines

-- Folding (using treesitter)
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.fillchars = {
  foldopen = "▼",
  foldclose = "▶",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- Session management
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }