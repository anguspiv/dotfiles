-- Git integration and version control tools
return {
  -- Git signs in the gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- Navigation
        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")

        -- Actions
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },

  -- LazyGit integration
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
    config = function()
      vim.g.lazygit_floating_window_winblend = 0
      vim.g.lazygit_floating_window_scaling_factor = 0.9
      vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
      vim.g.lazygit_floating_window_use_plenary = 0
      vim.g.lazygit_use_neovim_remote = 1
    end,
  },

  -- Better diff view
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "DiffView Open" },
      { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "DiffView Close" },
      { "<leader>gdh", "<cmd>DiffviewFileHistory<cr>", desc = "DiffView File History" },
      { "<leader>gdH", "<cmd>DiffviewFileHistory %<cr>", desc = "DiffView Current File History" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        merge_tool = {
          layout = "diff3_horizontal",
          disable_diagnostics = true,
        },
        file_history = {
          layout = "diff2_horizontal",
        },
      },
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 35,
        },
      },
      file_history_panel = {
        log_options = {
          git = {
            single_file = {
              diff_merges = "combined",
            },
            multi_file = {
              diff_merges = "first-parent",
            },
          },
        },
        win_config = {
          position = "bottom",
          height = 16,
        },
      },
      commit_log_panel = {
        win_config = {
          position = "bottom",
          height = 16,
        },
      },
      default_args = {
        DiffviewOpen = {},
        DiffviewFileHistory = {},
      },
      hooks = {},
      keymaps = {
        disable_defaults = false,
        view = {
          { "n", "<tab>", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle the file panel." } },
          { "n", "gf", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle the file panel" } },
          { "n", "<leader>e", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle the file panel" } },
          { "n", "<leader>co", "<cmd>DiffviewConflictChooseOurs<cr>", { desc = "Choose the OURS version of a conflict" } },
          { "n", "<leader>ct", "<cmd>DiffviewConflictChooseTheirs<cr>", { desc = "Choose the THEIRS version of a conflict" } },
          { "n", "<leader>cb", "<cmd>DiffviewConflictChooseBase<cr>", { desc = "Choose the BASE version of a conflict" } },
          { "n", "<leader>ca", "<cmd>DiffviewConflictChooseAll<cr>", { desc = "Choose all the versions of a conflict" } },
          { "n", "dx", "<cmd>DiffviewConflictChooseNone<cr>", { desc = "Delete the conflict region" } },
        },
        file_panel = {
          { "n", "j", "j", { desc = "Bring the cursor to the next file entry" } },
          { "n", "<down>", "j", { desc = "Bring the cursor to the next file entry" } },
          { "n", "k", "k", { desc = "Bring the cursor to the previous file entry." } },
          { "n", "<up>", "k", { desc = "Bring the cursor to the previous file entry." } },
          { "n", "<cr>", "<cmd>DiffviewOpen<cr>", { desc = "Open the diff for the selected entry." } },
          { "n", "o", "<cmd>DiffviewOpen<cr>", { desc = "Open the diff for the selected entry." } },
          { "n", "<2-LeftMouse>", "<cmd>DiffviewOpen<cr>", { desc = "Open the diff for the selected entry." } },
          { "n", "-", "<cmd>DiffviewToggleStage<cr>", { desc = "Stage / unstage the selected entry." } },
          { "n", "S", "<cmd>DiffviewStageAll<cr>", { desc = "Stage all entries." } },
          { "n", "U", "<cmd>DiffviewUnstageAll<cr>", { desc = "Unstage all entries." } },
          { "n", "X", "<cmd>DiffviewRestoreEntry<cr>", { desc = "Restore entry to the state on the left side." } },
          { "n", "L", "<cmd>DiffviewToggleLazyMode<cr>", { desc = "Toggle lazy mode." } },
          { "n", "R", "<cmd>DiffviewRefresh<cr>", { desc = "Update stats and entries in the file list." } },
          { "n", "<tab>", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle the file panel" } },
          { "n", "gf", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle the file panel" } },
          { "n", "<leader>e", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle the file panel" } },
          { "n", "g<C-x>", "<cmd>DiffviewClearState<cr>", { desc = "Clear the diff state." } },
          { "n", "[x", "<cmd>DiffviewPrev<cr>", { desc = "Open the previous diff" } },
          { "n", "]x", "<cmd>DiffviewNext<cr>", { desc = "Open the next diff" } },
        },
        file_history_panel = {
          { "n", "g!", "<cmd>DiffviewOptionsToggle<cr>", { desc = "Open the option panel" } },
          { "n", "<C-A-d>", "<cmd>DiffviewToggleShowDiffs<cr>", { desc = "Toggle show diffs" } },
          { "n", "zR", "<cmd>DiffviewExpandAll<cr>", { desc = "Expand all folds" } },
          { "n", "zM", "<cmd>DiffviewCollapseAll<cr>", { desc = "Collapse all folds" } },
          { "n", "j", "j", { desc = "Bring the cursor to the next file entry" } },
          { "n", "<down>", "j", { desc = "Bring the cursor to the next file entry" } },
          { "n", "k", "k", { desc = "Bring the cursor to the previous file entry." } },
          { "n", "<up>", "k", { desc = "Bring the cursor to the previous file entry." } },
          { "n", "<cr>", "<cmd>DiffviewOpen<cr>", { desc = "Open the diff for the selected entry." } },
          { "n", "o", "<cmd>DiffviewOpen<cr>", { desc = "Open the diff for the selected entry." } },
          { "n", "<2-LeftMouse>", "<cmd>DiffviewOpen<cr>", { desc = "Open the diff for the selected entry." } },
          { "n", "<c-b>", "<cmd>DiffviewScrollViewUp<cr>", { desc = "Scroll the view up" } },
          { "n", "<c-f>", "<cmd>DiffviewScrollViewDown<cr>", { desc = "Scroll the view down" } },
          { "n", "<tab>", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle the file panel" } },
          { "n", "gf", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle the file panel" } },
          { "n", "<leader>e", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle the file panel" } },
          { "n", "g<C-x>", "<cmd>DiffviewClearState<cr>", { desc = "Clear the diff state." } },
        },
        option_panel = {
          { "n", "<tab>", "<cmd>DiffviewToggleOption<cr>", { desc = "Change the current option" } },
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
          { "n", "<esc>", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        },
      },
    },
  },

  -- Git blame and history
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    opts = {
      enabled = false, -- disable by default, toggle with <leader>gb
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