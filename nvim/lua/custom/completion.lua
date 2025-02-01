require "custom.snippets"

vim.opt.completeopt = { "menu", "menuone", "fuzzy", "noinsert" }
vim.opt.shortmess:append "c"

local lspkind = require "lspkind"
lspkind.init {
  symbol_map = {
    copilot = "",
  },
}
local cmp = require "cmp"

cmp.setup {
  sources = {
    { name = "nvim_lsp" },
    { name = "copilot" },
    { name = "path" },
    { name = "buffer" },
  },
  mapping = {
    ["C-n"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
    ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
    ["<C-Space>"] = cmp.mapping.confirm { behavior = cmp.SelectBehavior.Insert, select = true },
    ["<C-e>"] = cmp.mapping.close,
    ["<C-y"] = cmp.mapping(
      cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      },
      { "i", "c" }
    ),
  },
  -- Enable luasnip to handle snippet expansion for nvim-cmp
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
}
