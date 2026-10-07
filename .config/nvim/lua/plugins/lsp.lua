-- Extra LSP servers and Mason tools.
-- Already configured elsewhere (don't repeat here):
--   vtsls  -> lazyvim.plugins.extras.lang.typescript (+ angular.lua)
--   jsonls -> lazyvim.plugins.extras.lang.json
--   jdtls  -> lazyvim.plugins.extras.lang.java
--   lua_ls -> LazyVim core
--   gopls  -> go.lua
--   dartls -> flutter-tools.nvim (flutter.lua)
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {},
        yamlls = {},
        dockerls = {},
        html = {},
        cssls = {},
        tailwindcss = {},
        eslint = {},
        pyright = {}, -- or switch to basedpyright (see LazyVim news)
        clangd = {},
      },
    },
  },

  {
    "mason-org/mason.nvim",
    -- `ensure_installed` is a list: LazyVim extends it (opts_extend), so use a plain table
    opts = {
      ensure_installed = {
        -- LSPs
        "lua-language-server",
        "bash-language-server",
        "json-lsp",
        "yaml-language-server",
        "dockerfile-language-server",
        "html-lsp",
        "css-lsp",
        "tailwindcss-language-server",
        "vtsls",
        "eslint-lsp",
        "pyright",
        "clangd",
        "gopls",
        "dart-debug-adapter", -- debug for Dart
        "angular-language-server", -- used by angular.lua
        -- Formatters/Linters used by conform/nvim-lint
        "prettierd",
        "stylua",
        "shfmt",
        "shellcheck",
        "clang-format",
      },
    },
  },
}
