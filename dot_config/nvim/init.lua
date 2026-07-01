-- LazyVim Configuration
-- Leader key setup (must be before lazy)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap and configure lazy.nvim + LazyVim
require("config.lazy")

-- Custom config modules not auto-loaded by LazyVim
require("config.ai")
require("config.claude-code").setup()
