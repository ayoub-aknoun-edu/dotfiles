return {
  -- LSP servers via lspconfig + mason
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim" },
    opts = function(_, opts)
      opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
        -- Core
        lua_ls = {},      -- Lua (for Neovim config)
        bashls = {},
        jsonls = {},
        yamlls = {},
        dockerls = {},
        html = {},
        cssls = {},
        tailwindcss = {},
        -- Web/TS/Angular
        vtsls = {},       -- better TS server (replaces tsserver)
        eslint = {},
        -- Python
        pyright = {},     -- or switch to basedpyright (see LazyVim news)
        -- C/C++
        clangd = {},
        -- Go
        gopls = {},
        -- Dart/Flutter
        dartls = {},
      })
    end,
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_extend("force", opts.ensure_installed or {}, {
        -- LSPs
        "lua-language-server", "bash-language-server", "json-lsp", "yaml-language-server",
        "dockerfile-language-server", "html-lsp", "css-lsp", "tailwindcss-language-server",
        "vtsls", "eslint-lsp",
        "pyright",
        "clangd",
        "gopls",
        "dart-debug-adapter", -- debug for Dart
        "angular-language-server", -- see angular section below
        -- Formatters/Linters used by conform/nvim-lint
        "prettierd", "stylua", "shfmt", "shellcheck", "clang-format",
      })
    end,
  },
}
