-- LSP Configuration overrides for LazyVim
-- Most servers are handled by LazyVim extras (typescript, eslint, json, tailwind, prisma, etc.)
local is_vscode = vim.g.vscode == 1

return {
  -- Custom server settings (merged with LazyVim defaults)
  {
    "neovim/nvim-lspconfig",
    enabled = not is_vscode,
    opts = {
      diagnostics = {
        underline = true,
        virtual_text = {
          prefix = "●",
          spacing = 4,
        },
        severity_sort = true,
        float = {
          border = "rounded",
          source = true,
        },
      },
      inlay_hints = {
        enabled = true,
      },
      servers = {
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        eslint = {
          settings = {
            workingDirectory = { mode = "auto" },
            experimental = {
              useFlatConfig = true,
            },
          },
        },
        tailwindcss = {
          filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
        },
        cssls = {},
        html = {},
        graphql = {},
      },
    },
  },

  -- Extra Mason tools not covered by LazyVim extras
  {
    "mason-org/mason.nvim",
    enabled = not is_vscode,
    opts = {
      ensure_installed = {
        "stylelint",
        "js-debug-adapter",
      },
    },
  },

  -- TypeScript utilities
  {
    "pmizio/typescript-tools.nvim",
    enabled = not is_vscode,
    dependencies = { "nvim-lua/plenary.nvim", "nvim-lspconfig" },
    opts = {
      settings = {
        tsserver_file_preferences = {
          importModuleSpecifierPreference = "relative",
          importModuleSpecifierEnding = "minimal",
        },
      },
    },
  },
}
