return {
  {
    "nvim-lua/plenary.nvim",
    "wakatime/vim-wakatime",
    {
      "vimpostor/vim-tpipeline",
      event = "VeryLazy",
      dependencies = {
        {
          "nvim-lualine/lualine.nvim",
          dependencies = {
            "nvim-tree/nvim-web-devicons",
          },
          event = "VeryLazy",
          config = function()
            local wk_status = require "custom.statusline"
            require("lualine").setup {
              options = {
                icons_enabled = true,
                theme = "ayu_dark",
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                  statusline = { "md" },
                  winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = false,
                refresh = {
                  statusline = 1000,
                  tabline = 1000,
                  winbar = 1000,
                },
              },
              sections = {
                lualine_a = {
                  {
                    "mode",
                    fmt = function(str)
                      return str:sub(1, 1)
                    end,
                  },
                },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { { "filename", color = { fg = "#48fb00" } } },
                lualine_x = {
                  {
                    wk_status,
                    cond = function()
                      return vim.g["loaded_wakatime"] == 1
                    end,
                  },
                  -- 'encoding',
                  -- 'fileformat',
                  -- 'filetype'
                },
                lualine_y = {
                  -- 'progress'
                },
                lualine_z = { "location" },
              },
              inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" },
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = {},
              },
              tabline = {},
              winbar = {},
              inactive_winbar = {},
              extensions = {},
            }
          end,
        },
      },
    },
    config = function()
      require("tpipeline").setup()
      vim.g.tpipeline_statusline = "%!tpipeline#stl#line()"
      vim.g.tpipeline_autoembed = 0
      vim.g.statusline = "%!tpipeline#stl#line()"
      vim.g.stl = "%!tpipeline#stl#line()"
    end,
  },
}
