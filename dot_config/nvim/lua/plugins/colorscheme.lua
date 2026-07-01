-- Colorscheme and UI theming customizations
return {
  -- Tokyo Night: custom highlight overrides
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
      on_highlights = function(highlights, colors)
        -- Transparent diagnostic virtual text backgrounds
        highlights.DiagnosticVirtualTextError = { bg = colors.none, fg = colors.red1 }
        highlights.DiagnosticVirtualTextWarn = { bg = colors.none, fg = colors.yellow }
        highlights.DiagnosticVirtualTextInfo = { bg = colors.none, fg = colors.blue1 }
        highlights.DiagnosticVirtualTextHint = { bg = colors.none, fg = colors.blue7 }

        -- Terminal buffer visual distinction
        highlights.TerminalNormal = { bg = "#14151c", fg = colors.fg }
        highlights.TerminalNormalNC = { bg = "#12131a", fg = colors.fg_dark }

        -- Diff highlighting: clearer add/delete/change colors
        highlights.DiffAdd = { bg = "#1a2e1a" } -- green tint for added lines
        highlights.DiffDelete = { bg = "#2e1a1a" } -- red tint for deleted lines
        highlights.DiffChange = { bg = "#1a1a2e" } -- blue tint for changed lines
        highlights.DiffText = { bg = "#2a2a4e", bold = true } -- brighter blue for changed text within a line

        -- Inline diff text (used by native diff mode)
        highlights.Added = { fg = "#9ece6a", bg = "#1a2e1a" }
        highlights.Removed = { fg = "#f7768e", bg = "#2e1a1a" }
        highlights.Changed = { fg = "#7aa2f7", bg = "#1a1a2e" }
      end,
    },
  },

  -- Catppuccin (alternative, lazy-loaded)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      flavour = "macchiato",
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
      },
    },
  },

  -- Lualine: custom terminal indicator and LSP clients display
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Add terminal indicator to lualine_c
      table.insert(opts.sections.lualine_c, {
        function()
          return vim.bo.buftype == "terminal" and " TERMINAL" or ""
        end,
        color = { fg = "#7dcfff", bg = "#1f2335", gui = "bold" },
        padding = { left = 1, right = 1 },
      })

      -- Add LSP clients to lualine_x
      table.insert(opts.sections.lualine_x, 1, {
        function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients == 0 then return "" end
          local names = {}
          for _, client in ipairs(clients) do
            table.insert(names, client.name)
          end
          return " " .. table.concat(names, ", ")
        end,
        cond = function()
          return #vim.lsp.get_clients({ bufnr = 0 }) > 0
        end,
      })
    end,
  },

  -- Bufferline: snacks explorer offset
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        offsets = {
          {
            filetype = "snacks_layout_box",
            text = "Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },

  -- Noice: disable in VSCode
  {
    "folke/noice.nvim",
    cond = function()
      return not vim.g.vscode
    end,
  },
}
