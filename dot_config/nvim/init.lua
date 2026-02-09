-- Modern Neovim Configuration
-- Generated for: Angus Perkerson <angus.perkerson@disney.com>
-- Machine: development (high)
-- Optimized for TypeScript/JavaScript Frontend Development

-- Detect if running in VSCode/Cursor (vscode-neovim extension)
-- This must be set early before any other configuration
vim.g.vscode = vim.g.vscode or 0

-- Performance optimization: disable some built-in plugins
local disabled_built_ins = {
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

-- Leader key setup (must be before lazy setup)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim
require("lazy").setup({
  spec = {
    -- Import plugin configurations
    { import = "plugins" },
  },
  defaults = {
    lazy = false, -- plugins are not lazy-loaded by default
    version = false, -- always use the latest git commit
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true, -- reset the package path to improve startup time
    rtp = {
      reset = true, -- reset the runtime path to improve startup time
      paths = {}, -- add any custom paths here that you want to includes in the rtp
      disabled_plugins = disabled_built_ins,
    },
  },
})

-- Load core configuration
require("config.options")
require("config.keymaps")
require("config.autocmds")
-- AI tools integration
require("config.ai")
-- Claude Code integration enhancements
require("config.claude-code").setup()

-- Load colorscheme
vim.cmd.colorscheme("tokyonight-night")
