return {
  -- Better fzf-lua config
  {
    "ibhagwan/fzf-lua",
    opts = {
      winopts = {
        preview = { layout = "vertical", vertical = "up:40%" },
      },
    },
  },

  -- Trouble.nvim: diagnostics with better defaults
  {
    "folke/trouble.nvim",
    opts = {
      focus = true,
      auto_preview = true,
    },
  },

  -- which-key: group labels for custom keymaps
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      vim.list_extend(opts.spec, {
        { "<leader>t", group = "test" },
      })
    end,
  },

  -- Gitsigns: add blame line and better diff
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
