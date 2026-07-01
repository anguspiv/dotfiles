-- Custom keymaps (non-LazyVim-default)
-- LazyVim already provides: window nav, buffer nav, move lines, splits,
-- tabs, terminal, indenting, escape/clear, save, quit, lazy, LSP, etc.

local map = vim.keymap.set

-- Centered scrolling and search (LazyVim doesn't center these)
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up (centered)" })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })
map("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })

-- Better paste (don't overwrite register)
map("x", "<leader>p", '"_dP', { desc = "Paste without overwriting register" })

-- Centered diagnostic navigation
map("n", "]d", function()
  vim.diagnostic.goto_next()
  vim.cmd("normal! zz")
end, { desc = "Next diagnostic (centered)" })
map("n", "[d", function()
  vim.diagnostic.goto_prev()
  vim.cmd("normal! zz")
end, { desc = "Prev diagnostic (centered)" })
