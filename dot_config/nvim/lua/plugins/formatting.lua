-- Formatting and linting customizations on top of LazyVim defaults
-- LazyVim extras handle: conform.nvim, nvim-lint, eslint, prettier, biome
return {
  -- Conform: add extra formatter mappings not covered by LazyVim extras
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        fish = { "fish_indent" },
        sh = { "shfmt" },
        handlebars = { "prettier" },
      },
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    },
  },

  -- nvim-lint: extra linters not covered by LazyVim extras
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        fish = { "fish" },
        dockerfile = { "hadolint" },
        yaml = { "yamllint" },
        json = { "jsonlint" },
        markdown = { "markdownlint" },
      },
    },
  },

  -- Better quickfix window
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    dependencies = {
      {
        "junegunn/fzf",
        build = "./install --bin",
      },
    },
  },
}
