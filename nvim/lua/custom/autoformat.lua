local util = require "conform.util"
local setup = function()
  -- Autoformatting Setup
  local conform = require "conform"
  conform.setup {
    formatters = {
      biome = {
        command = util.from_node_modules "biome",
        stdin = true,
        args = { "format", "--stdin-file-path", "$FILENAME" },
      },
    },
    formatters_by_ft = {
      typescript = { "biome" },
      html = { "biome" },
      css = { "biome" },
      typescriptreact = { "biome" },
      javascript = { "biome" },
      json = { "biome" },
      lua = { "stylua" },
      sh = { "shfmt" },
      python = { "ruff_fix", "ruff_format" },
      bash = { "shfmt" },
    },
  }
  conform.formatters.injected = {
    options = {
      ignore_errors = false,
      lang_to_formatters = {
        sql = { "sleek" },
      },
    },
  }

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("custom-conform", { clear = true }),
    callback = function(args)
      local ft = vim.bo.filetype
      if ft == "blade" then
        require("conform").format {
          bufnr = args.buf,
          lsp_fallback = false,
          quiet = true,
          async = true,
        }

        return
      end

      require("conform").format {
        bufnr = args.buf,
        lsp_fallback = true,
        quiet = true,
      }
    end,
  })
end

setup()

return { setup = setup }
