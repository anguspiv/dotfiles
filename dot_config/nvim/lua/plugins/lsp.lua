-- LSP Configuration for TypeScript/JavaScript Development
return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "b0o/schemastore.nvim", -- JSON schemas for LSP
    },
    opts = {
      -- Global capabilities
      capabilities = {},
      -- Global server settings
      servers = {
        -- TypeScript/JavaScript
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
        -- ESLint
        eslint = {
          settings = {
            workingDirectory = { mode = "auto" },
            experimental = {
              useFlatConfig = true,
            },
          },
        },
        -- CSS
        cssls = {},
        -- HTML
        html = {},
        -- JSON
        jsonls = function()
          local has_schemastore, schemastore = pcall(require, "schemastore")
          local schemas = has_schemastore and schemastore.json.schemas() or {}
          
          return {
            settings = {
              json = {
                schemas = schemas,
                validate = { enable = true },
              },
            },
          }
        end,
        -- Tailwind CSS
        tailwindcss = {
          filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
        },
        -- GraphQL
        graphql = {},
        -- Prisma
        prismals = {},
      },
    },
    config = function(_, opts)
      local servers = opts.servers
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities(),
        opts.capabilities or {}
      )

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        require("lspconfig")[server].setup(server_opts)
      end

      -- Get all servers that should be automatically installed
      local ensure_installed = {}
      for server, _ in pairs(servers) do
        ensure_installed[#ensure_installed + 1] = server
      end

      require("mason-lspconfig").setup({
        ensure_installed = ensure_installed,
        handlers = { setup },
      })
    end,
  },

  -- Mason: LSP installer
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        -- Language servers
        "typescript-language-server",
        "eslint-lsp",
        "css-lsp",
        "html-lsp",
        "json-lsp",
        "tailwindcss-language-server",
        "graphql-language-service-cli",
        "prisma-language-server",
        
        -- Formatters
        "prettier",
        "eslint_d",
        "stylelint",
        
        -- Linters
        "eslint_d",
        
        -- Debuggers
        "js-debug-adapter",
        "node-debug2-adapter",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  -- TypeScript utilities
  {
    "jose-elias-alvarez/typescript.nvim",
    dependencies = { "nvim-lspconfig" },
    opts = {
      server = {
        settings = {
          typescript = {
            preferences = {
              importModuleSpecifier = "relative",
              importModuleSpecifierEnding = "minimal",
            },
          },
        },
      },
    },
  },

}