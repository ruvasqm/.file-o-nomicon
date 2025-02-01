return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
        -- used for completion, annotations and signatures of Neovim apis
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            -- Load luvit types when the `vim.uv` word is found
            { path = "luvit-meta/library", words = { "vim%.uv" } },
          },
        },
      },
      {
        "saghen/blink.cmp",
        -- optional: provides snippets for the snippet source
        dependencies = "rafamadriz/friendly-snippets",

        -- use a release tag to download pre-built binaries
        version = "0.10.0",
        -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
        -- build = "cargo build --release",
        -- If you use nix, you can build from source using latest nightly rust with:
        -- build = 'nix run .#build-plugin',

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
          -- 'default' for mappings similar to built-in completion
          -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
          -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
          -- See the full "keymap" documentation for information on defining your own keymap.
          keymap = { preset = "default" },

          appearance = {
            -- Sets the fallback highlight groups to nvim-cmp's highlight groups
            -- Useful for when your theme doesn't support blink.cmp
            -- Will be removed in a future release
            use_nvim_cmp_as_default = true,
            -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = "mono",
          },
          fuzzy = {
            -- When enabled, allows for a number of typos relative to the length of the query
            -- Disabling this matches the behavior of fzf
            use_typo_resistance = true,
            -- Frecency tracks the most recently/frequently used items and boosts the score of the item
            use_frecency = true,
            -- Proximity bonus boosts the score of items matching nearby words
            use_proximity = true,
            -- UNSAFE!! When enabled, disables the lock and fsync when writing to the frecency database. This should only be used on unsupported platforms (i.e. alpine termux)
            use_unsafe_no_lock = false,
            -- Controls which sorts to use and in which order, falling back to the next sort if the first one returns nil
            -- You may pass a function instead of a string to customize the sorting
            sorts = { "score", "sort_text" },

            prebuilt_binaries = {
              -- Whether or not to automatically download a prebuilt binary from github. If this is set to `false`
              -- you will need to manually build the fuzzy binary dependencies by running `cargo build --release`
              download = true,
              -- Ignores mismatched version between the built binary and the current git sha, when building locally
              ignore_version_mismatch = false,
              -- When downloading a prebuilt binary, force the downloader to resolve this version. If this is unset
              -- then the downloader will attempt to infer the version from the checked out git tag (if any).
              --
              -- Beware that if the fuzzy matcher changes while tracking main then this may result in blink breaking.
              force_version = nil,
              -- When downloading a prebuilt binary, force the downloader to use this system triple. If this is unset
              -- then the downloader will attempt to infer the system triple from `jit.os` and `jit.arch`.
              -- Check the latest release for all available system triples
              --
              -- Beware that if the fuzzy matcher changes while tracking main then this may result in blink breaking.
              force_system_triple = nil,
              -- Extra arguments that will be passed to curl like { 'curl', ..extra_curl_args, ..built_in_args }
              extra_curl_args = {},
            },
          },

          -- Default list of enabled providers defined so that you can extend it
          -- elsewhere in your config, without redefining it, due to `opts_extend`
          sources = {
            default = { "lsp", "path", "snippets", "buffer" },
          },
        },
        opts_extend = { "sources.default" },
      },
      { "Bilal2453/luvit-meta", lazy = true },
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      { "j-hui/fidget.nvim", opts = {} },
      { "https://git.sr.ht/~whynothugo/lsp_lines.nvim" },

      -- Autoformatting
      "stevearc/conform.nvim",

      -- Schema information
      "b0o/SchemaStore.nvim",
    },
    config = function()
      -- Don't do LSP stuff if we're in Obsidian Edit mode
      if vim.g.obsidian then
        return
      end

      local extend = function(name, key, values)
        local mod = require(string.format("lspconfig.configs.%s", name))
        local default = mod.default_config
        local keys = vim.split(key, ".", { plain = true })
        while #keys > 0 do
          local item = table.remove(keys, 1)
          default = default[item]
        end

        if vim.islist(default) then
          for _, value in ipairs(default) do
            table.insert(values, value)
          end
        else
          for item, value in pairs(default) do
            if not vim.tbl_contains(values, item) then
              values[item] = value
            end
          end
        end
        return values
      end

      local capabilities = nil
      if pcall(require, "cmp_nvim_lsp") then
        capabilities = require("cmp_nvim_lsp").default_capabilities()
      end

      local lspconfig = require "lspconfig"

      local servers = {
        bashls = true,
        gopls = {
          settings = {
            gopls = {
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        },
        lua_ls = {
          server_capabilities = {
            semanticTokensProvider = vim.NIL,
          },
        },
        rust_analyzer = true,
        svelte = true,
        templ = true,
        taplo = true,
        intelephense = true,
        emmet_ls = true,

        pyright = true,
        mojo = { manual_install = true },

        -- Enabled biome formatting, turn off all the other ones generally
        biome = {
          cmd = { "biome", "lsp-proxy" },
          filetypes = {
            "astro",
            "css",
            "graphql",
            "javascript",
            "javascriptreact",
            "json",
            "jsonc",
            "svelte",
            "typescript",
            "typescript.tsx",
            "typescriptreact",
            "vue",
          },
          server_capabilities = {
            documentFormattingProvider = true,
          },
        },
        ts_ls = {
          root_dir = require("lspconfig").util.root_pattern "package.json",
          single_file = false,
          server_capabilities = {
            documentFormattingProvider = false,
          },
        },
        -- denols = true,
        jsonls = {
          server_capabilities = {
            documentFormattingProvider = false,
          },
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },

        -- cssls = {
        --   server_capabilities = {
        --     documentFormattingProvider = false,
        --   },
        -- },

        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                enable = false,
                url = "",
              },
              -- schemas = require("schemastore").yaml.schemas(),
            },
          },
        },

        ols = {},
        racket_langserver = { manual_install = true },
        roc_ls = { manual_install = true },

        ocamllsp = {
          manual_install = true,
          cmd = { "dune", "tools", "exec", "ocamllsp" },
          -- cmd = { "dune", "exec", "ocamllsp" },
          settings = {
            codelens = { enable = true },
            inlayHints = { enable = true },
            syntaxDocumentation = { enable = true },
          },

          server_capabilities = { semanticTokensProvider = false },

          -- TODO: Check if i still need the filtypes stuff i had before
        },

        gleam = {
          manual_install = true,
        },

        -- elixirls = {
        --   cmd = { "/home/tjdevries/.local/share/nvim/mason/bin/elixir-ls" },
        --   root_dir = require("lspconfig.util").root_pattern { "mix.exs" },
        --   -- server_capabilities = {
        --   --   -- completionProvider = true,
        --   --   definitionProvider = true,
        --   --   documentFormattingProvider = false,
        --   -- },
        -- },

        -- lexical = {
        --   cmd = { "/home/tjdevries/.local/share/nvim/mason/bin/lexical", "server" },
        --   root_dir = require("lspconfig.util").root_pattern { "mix.exs" },
        --   server_capabilities = {
        --     completionProvider = vim.NIL,
        --     definitionProvider = true,
        --   },
        -- },

        clangd = {
          -- cmd = { "clangd", unpack(require("custom.clangd").flags) },
          -- TODO: Could include cmd, but not sure those were all relevant flags.
          --    looks like something i would have added while i was floundering
          init_options = { clangdFileStatus = true },

          filetypes = { "c", "h" },
        },

        tailwindcss = {
          init_options = {
            userLanguages = {
              elixir = "phoenix-heex",
              eruby = "erb",
              heex = "phoenix-heex",
            },
          },
          filetypes = extend("tailwindcss", "filetypes", { "ocaml.mlx" }),
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = {
                  [[class: "([^"]*)]],
                  [[className="([^"]*)]],
                },
              },
              includeLanguages = extend("tailwindcss", "settings.tailwindCSS.includeLanguages", {
                ["ocaml.mlx"] = "html",
              }),
            },
          },
        },
      }

      local servers_to_install = vim.tbl_filter(function(key)
        local t = servers[key]
        if type(t) == "table" then
          return not t.manual_install
        else
          return t
        end
      end, vim.tbl_keys(servers))

      require("mason").setup()
      local ensure_installed = {
        "stylua",
        "ruff",
        "lua_ls",
        "delve",
        -- "tailwind-language-server",
      }

      vim.list_extend(ensure_installed, servers_to_install)
      require("mason-tool-installer").setup { ensure_installed = ensure_installed }

      for name, config in pairs(servers) do
        if config == true then
          config = {}
        end
        config = vim.tbl_deep_extend("force", {}, {
          capabilities = capabilities,
        }, config)

        lspconfig[name].setup(config)
      end

      local disable_semantic_tokens = {
        lua = true,
      }

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

          local settings = servers[client.name]
          if type(settings) ~= "table" then
            settings = {}
          end

          local builtin = require "telescope.builtin"

          vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
          vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = 0 })
          vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = 0 })
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = 0 })
          vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, { buffer = 0 })
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })

          vim.keymap.set("n", "<space>cr", vim.lsp.buf.rename, { buffer = 0 })
          vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, { buffer = 0 })
          vim.keymap.set("n", "<space>wd", builtin.lsp_document_symbols, { buffer = 0 })

          local filetype = vim.bo[bufnr].filetype
          if disable_semantic_tokens[filetype] then
            client.server_capabilities.semanticTokensProvider = nil
          end

          -- Override server capabilities
          if settings.server_capabilities then
            for k, v in pairs(settings.server_capabilities) do
              if v == vim.NIL then
                ---@diagnostic disable-next-line: cast-local-type
                v = nil
              end

              client.server_capabilities[k] = v
            end
          end
        end,
      })

      require("custom.autoformat").setup()

      require("lsp_lines").setup()
      vim.diagnostic.config { virtual_text = true, virtual_lines = false }

      vim.keymap.set("", "<leader>l", function()
        local config = vim.diagnostic.config() or {}
        if config.virtual_text then
          vim.diagnostic.config { virtual_text = false, virtual_lines = true }
        else
          vim.diagnostic.config { virtual_text = true, virtual_lines = false }
        end
      end, { desc = "Toggle lsp_lines" })
    end,
  },
}
