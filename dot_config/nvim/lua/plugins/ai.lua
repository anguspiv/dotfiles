-- AI integration for agentic coding with Claude and GitHub Copilot
return {
  -- GitHub Copilot
  {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
      -- Use fnm-managed Node 22 (required: Node 20+ for Copilot)
      vim.g.copilot_node_command = vim.fn.expand("~/.local/share/fnm/node-versions/v22.22.0/installation/bin/node")
      
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_tab_fallback = ""
      
      -- Custom keymaps for Copilot
      local keymap = vim.keymap.set
      keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { expr = true, replace_keycodes = false })
      keymap("i", "<C-H>", "copilot#Accept('<C-H>')", { expr = true, replace_keycodes = false })
      keymap("i", "<C-L>", "<Plug>(copilot-accept-word)")
      keymap("i", "<C-Right>", "<Plug>(copilot-accept-word)")
      keymap("i", "<C-Down>", "<Plug>(copilot-next)")
      keymap("i", "<C-Up>", "<Plug>(copilot-previous)")
      
      -- Disable Copilot in certain file types
      vim.g.copilot_filetypes = {
        ["*"] = false,
        javascript = true,
        typescript = true,
        javascriptreact = true,
        typescriptreact = true,
        python = true,
        lua = true,
        rust = true,
        go = true,
        html = true,
        css = true,
        scss = true,
        json = true,
        markdown = true,
      }
    end,
  },

  -- Copilot Chat for Claude-like interactions
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      "github/copilot.vim",
      "nvim-lua/plenary.nvim",
    },
    opts = {
      debug = false,
      show_help = "yes",
      prompts = {
        Explain = "Please explain how the following code works.",
        Review = "Please review the following code and provide suggestions for improvement.",
        Tests = "Please explain how the selected code works, then generate unit tests for it.",
        Refactor = "Please refactor the following code to improve its clarity and readability.",
        FixCode = "Please fix the following code to make it work as intended.",
        BetterNamings = "Please provide better names for the following variables and functions.",
        Documentation = "Please provide documentation for the following code.",
        SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
        SwaggerJSDoc = "Please write JSDoc for the following API using Swagger.",
        Summarize = "Please summarize the following text.",
        Spelling = "Please correct any grammar and spelling errors in the following text.",
        Wording = "Please improve the grammar and wording of the following text.",
        Concise = "Please rewrite the following text to make it more concise.",
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")
      
      chat.setup(opts)

      -- Custom keymaps for CopilotChat
      vim.keymap.set("n", "<leader>ccq", function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
          chat.ask(input, { selection = select.buffer })
        end
      end, { desc = "CopilotChat - Quick chat" })

      vim.keymap.set("n", "<leader>cch", function()
        local actions = require("CopilotChat.actions")
        require("CopilotChat.integrations.telescope").pick(actions.help_actions())
      end, { desc = "CopilotChat - Help actions" })

      vim.keymap.set("n", "<leader>ccp", function()
        local actions = require("CopilotChat.actions")
        require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
      end, { desc = "CopilotChat - Prompt actions" })

      vim.keymap.set("x", "<leader>ccp", function()
        local actions = require("CopilotChat.actions")
        require("CopilotChat.integrations.telescope").pick(actions.prompt_actions({
          selection = select.visual,
        }))
      end, { desc = "CopilotChat - Prompt actions" })
    end,
    event = "VeryLazy",
    keys = {
      { "<leader>ccb", ":CopilotChatBuffer ", desc = "CopilotChat - Chat with current buffer" },
      { "<leader>cce", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
      { "<leader>cct", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
      { "<leader>ccr", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
      { "<leader>ccf", "<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor code" },
      { "<leader>ccn", "<cmd>CopilotChatBetterNamings<cr>", desc = "CopilotChat - Better Naming" },
      { "<leader>ccv", ":CopilotChatVisual ", mode = "x", desc = "CopilotChat - Open in vertical split" },
      { "<leader>ccx", ":CopilotChatInline<cr>", mode = "x", desc = "CopilotChat - Inline chat" },
    },
  },

  -- Claude.vim for direct Claude integration
  -- Note: This plugin doesn't exist yet, but when using Claude Code CLI,
  -- you can interact with it via terminal commands instead
  -- Disabled until official plugin is released
  -- {
  --   "anthropics/claude.vim",
  --   enabled = false,
  -- },
}
