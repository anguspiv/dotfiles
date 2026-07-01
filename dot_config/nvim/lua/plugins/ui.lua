-- UI customizations on top of LazyVim defaults
return {
  -- Enhanced command-line with fuzzy completion
  {
    "gelguy/wilder.nvim",
    event = "CmdlineEnter",
    dependencies = {
      {
        "romgrk/fzy-lua-native",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    config = function()
      local wilder = require("wilder")
      wilder.setup({
        modes = { ":", "/", "?" },
        next_key = "<Tab>",
        previous_key = "<S-Tab>",
        accept_key = "<Down>",
        reject_key = "<Up>",
      })

      wilder.set_option("renderer", wilder.popupmenu_renderer(wilder.popupmenu_border_theme({
        highlights = {
          border = "Normal",
          accent = wilder.make_hl("WilderAccent", "Pmenu", { { a = 1 }, { a = 1 }, { foreground = "#f4468f" } }),
        },
        border = "rounded",
        max_height = "75%",
        min_height = 0,
        prompt_position = "top",
        reverse = 0,
      })))

      local fuzzy_filter = function()
        local has_fzy, fzy = pcall(require, "fzy-lua-native")
        if has_fzy then
          return wilder.lua_fzy_filter()
        else
          return wilder.vim_fuzzy_filter()
        end
      end

      wilder.set_option("pipeline", {
        wilder.branch(
          wilder.cmdline_pipeline({
            fuzzy = 1,
            fuzzy_filter = fuzzy_filter(),
          }),
          wilder.vim_search_pipeline()
        ),
      })
    end,
  },

  -- Dashboard: custom logo (extends LazyVim dashboard-nvim extra)
  {
    "nvimdev/dashboard-nvim",
    opts = function(_, opts)
      local logo = [[
      ██████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗
      ██╔══██╗██╔════╝██║   ██║██║   ██║██║████╗ ████║
      ██║  ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
      ██║  ██║██╔══╝  ╚██╗ ██╔╝██║   ██║██║██║╚██╔╝██║
      ██████╔╝███████╗ ╚████╔╝ ╚██████╔╝██║██║ ╚═╝ ██║
      ╚═════╝ ╚══════╝  ╚═══╝   ╚═════╝ ╚═╝╚═╝     ╚═╝
      ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"
      opts.config = opts.config or {}
      opts.config.header = vim.split(logo, "\n")
    end,
  },
}
