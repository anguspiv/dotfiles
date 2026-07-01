-- Treesitter customizations on top of LazyVim defaults
return {
  -- Add extra parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "css",
        "scss",
        "graphql",
        "jsonc",
        "prisma",
      },
    },
  },

  -- Extend textobjects with extra move keymaps
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = {
      move = {
        keys = {
          goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
          goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
          goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
          goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
        },
      },
    },
  },
}
