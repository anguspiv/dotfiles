-- Git plugin customizations on top of LazyVim defaults
-- LazyVim handles: gitsigns, lazygit (via snacks)
return {
  -- Snacks: opaque lazygit float (override winblend)
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        win = {
          wo = {
            winblend = 0,
          },
        },
      },
    },
  },

  -- Diffview: advanced diff/merge tool (not in LazyVim)
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "DiffView Open" },
      { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "DiffView Close" },
      { "<leader>gdh", "<cmd>DiffviewFileHistory<cr>", desc = "DiffView File History" },
      { "<leader>gdH", "<cmd>DiffviewFileHistory %<cr>", desc = "DiffView Current File History" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { layout = "diff2_horizontal" },
        merge_tool = { layout = "diff3_horizontal", disable_diagnostics = true },
        file_history = { layout = "diff2_horizontal" },
      },
      file_panel = {
        listing_style = "tree",
        tree_options = { flatten_dirs = true, folder_statuses = "only_folded" },
        win_config = { position = "left", width = 35 },
      },
    },
  },

  -- Git blame (not in LazyVim)
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    opts = {
      enabled = false,
      message_template = " <summary> • <date> • <author> • <<sha>>",
      date_format = "%m-%d-%Y %H:%M:%S",
      virtual_text_column = 1,
    },
    keys = {
      { "<leader>gbt", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git Blame" },
      { "<leader>gbe", "<cmd>GitBlameEnable<cr>", desc = "Enable Git Blame" },
      { "<leader>gbd", "<cmd>GitBlameDisable<cr>", desc = "Disable Git Blame" },
    },
  },
}
