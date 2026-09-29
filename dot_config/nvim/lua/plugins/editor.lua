-- Editor plugin customizations on top of LazyVim defaults
return {
  -- Trouble: auto-focus and preview
  {
    "folke/trouble.nvim",
    opts = {
      focus = true,
      auto_preview = true,
    },
  },

  -- which-key: extra group labels
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      vim.list_extend(opts.spec, {
        { "<leader>t", group = "test" },
      })
    end,
  },

  -- Gitsigns: enable inline blame
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 300,
        virt_text_pos = "eol",
      },
    },
  },
}
